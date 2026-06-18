import 'dart:async';
import 'dart:io';
import 'dart:ui' show Size;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../core/camera/camera_controller.dart';
import '../../core/camera/frame_processor.dart';
import '../../core/ml/scene_classifier.dart';
import '../../core/ml/object_detector.dart';
import '../../core/ml/face_detector.dart';
import '../../core/ml/line_detector.dart';
import '../../core/composition/composition_engine.dart';
import '../../core/composition/guide_animator.dart';
import '../../core/filter/filter_recommender.dart';
import '../../core/filter/filter_service.dart';
import '../../core/lut/lut_library.dart';
import '../../core/storage/photo_repository.dart';
import '../../core/storage/export_service.dart';
import '../../models/composition_result.dart';
import '../../models/filter_preset.dart';
import '../../models/photo.dart' as model;

enum CameraMode { normal, composition, filter }

class CameraViewModel extends ChangeNotifier {
  final CameraControllerService cameraService = CameraControllerService();
  FrameProcessor? _frameProcessor;

  // ML detectors - lazily initialized to avoid crashes on devices without Play Services
  SceneClassifier? _sceneClassifier;
  ObjectDetectorService? _objectDetector;
  FaceDetectorService? _faceDetector;
  LineDetectorService? _lineDetector;
  bool _mlAvailable = false;

  // Analysis engines
  final CompositionEngine compositionEngine = CompositionEngine();
  final GuideAnimator guideAnimator = GuideAnimator();
  final FilterRecommender filterRecommender = FilterRecommender();
  final LutLibrary lutLibrary = LutLibrary();
  final PhotoRepository photoRepository = PhotoRepository();
  final ExportService exportService = ExportService();
  final FilterService filterService = FilterService();

  // State
  CameraMode _mode = CameraMode.normal;
  CompositionResult? _compositionResult;
  FilterPreset? _selectedFilter;
  List<FilterPreset> _recommendedFilters = [];
  bool _isAnalyzing = false;
  bool _showFilterPanel = false;
  CameraDescription? _currentCamera;

  CameraMode get mode => _mode;
  CompositionResult? get compositionResult => _compositionResult;
  FilterPreset? get selectedFilter => _selectedFilter;
  List<FilterPreset> get recommendedFilters => _recommendedFilters;
  bool get isAnalyzing => _isAnalyzing;
  bool get showFilterPanel => _showFilterPanel;
  bool get mlAvailable => _mlAvailable;
  double get guideAlpha => 1.0;

  Future<void> initialize() async {
    await cameraService.initialize();
    _initML();
    await _startFrameProcessing();
  }

  void _initML() {
    try {
      _sceneClassifier = SceneClassifier();
      _objectDetector = ObjectDetectorService();
      _faceDetector = FaceDetectorService();
      _lineDetector = LineDetectorService();
      _mlAvailable = true;
      debugPrint('ML Kit initialized successfully');
    } catch (e) {
      _mlAvailable = false;
      debugPrint('ML Kit not available: $e');
    }
  }

  Future<void> _startFrameProcessing() async {
    final controller = cameraService.controller;
    if (controller == null) return;
    _frameProcessor = FrameProcessor(cameraService);
    await _frameProcessor!.startProcessing(onFrame: _processFrame, skipFrames: 3);
  }

  void _processFrame(CameraImage image) async {
    if (!_mlAvailable || _mode != CameraMode.composition) return;
    if (_currentCamera == null) {
      final cameras = cameraService.cameras;
      if (cameras.isNotEmpty) _currentCamera = cameras[cameraService.selectedCameraIndex];
    }
    if (_currentCamera == null) return;
    try {
      final results = await Future.wait([
        _sceneClassifier!.classify(image, _currentCamera!),
        _objectDetector!.detectMainSubject(image, _currentCamera!),
        _lineDetector!.detectPoseLines(image, _currentCamera!),
      ]);
      final sceneType = results[0] as SceneType;
      final subjectRect = results[1] as Rect?;
      final lines = results[2] as List<Offset>;
      final result = compositionEngine.analyze(sceneType: sceneType, subjectRect: subjectRect, lines: lines);
      updateComposition(result);
      if (_recommendedFilters.isEmpty) {
        _recommendedFilters = filterRecommender.recommend(sceneType);
      }
    } catch (_) {}
  }

  void setMode(CameraMode mode) {
    _mode = mode;
    if (mode == CameraMode.composition && _mlAvailable) {
      guideAnimator.show();
      _isAnalyzing = true;
    } else {
      guideAnimator.hide();
      _compositionResult = null;
    }
    notifyListeners();
  }

  void updateComposition(CompositionResult result) {
    _compositionResult = result;
    _isAnalyzing = false;
    notifyListeners();
  }

  void selectFilter(FilterPreset filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void toggleFilterPanel() {
    _showFilterPanel = !_showFilterPanel;
    notifyListeners();
  }

  void switchCompositionScheme() {
    if (_compositionResult == null) return;
    final rules = _compositionResult!.recommendedRules;
    if (rules.isEmpty) return;
    _schemeIndex = (_schemeIndex + 1) % rules.length;
    if (_mlAvailable) _isAnalyzing = true;
    notifyListeners();
  }

  int _schemeIndex = 0;

  Future<String?> takePhoto() async {
    final xfile = await cameraService.takePhoto();
    if (xfile == null) return null;
    String path = await exportService.saveToAppStorage(XFile(xfile.path), filterName: _selectedFilter?.name);
    if (_selectedFilter != null && _selectedFilter!.name != 'normal') {
      final processor = lutLibrary.getFilter(_selectedFilter!);
      if (processor != null) {
        final filteredPath = path.replaceAll('.jpg', '_${_selectedFilter!.name}.jpg');
        try {
          path = await filterService.applyFilter(
            inputPath: path, outputPath: filteredPath, lutProcessor: processor,
            strength: _selectedFilter!.defaultStrength,
            faceRect: _compositionResult?.subjectRect,
            imageSize: const Size(1080.0, 1920.0),
          );
        } catch (_) {}
      }
    }
    final photo = model.Photo(
      localPath: path, thumbnailPath: path, createdAt: DateTime.now(),
      filterName: _selectedFilter?.name, compositionType: _compositionResult?.sceneLabel,
    );
    await photoRepository.insert(photo);
    return path;
  }

  @override
  void dispose() {
    _frameProcessor?.dispose();
    _sceneClassifier?.dispose();
    _objectDetector?.dispose();
    _faceDetector?.dispose();
    _lineDetector?.dispose();
    cameraService.dispose();
    lutLibrary.dispose();
    photoRepository.close();
    super.dispose();
  }
}