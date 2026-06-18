import 'dart:async';
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
import '../../core/filter/portrait_mask.dart';
import '../../core/lut/lut_library.dart';
import '../../core/storage/photo_repository.dart';
import '../../core/storage/export_service.dart';
import 'dart:ui' show Size;
import '../../models/composition_result.dart';
import '../../models/filter_preset.dart';
import '../../core/filter/filter_service.dart';
import '../../models/photo.dart' as model;

enum CameraMode { normal, composition, filter }

class CameraViewModel extends ChangeNotifier {
  final CameraControllerService cameraService = CameraControllerService();
  FrameProcessor? _frameProcessor;

  // ML detectors
  final SceneClassifier sceneClassifier = SceneClassifier();
  final ObjectDetectorService objectDetector = ObjectDetectorService();
  final FaceDetectorService faceDetector = FaceDetectorService();
  final LineDetectorService lineDetector = LineDetectorService();

  // Analysis engines
  final CompositionEngine compositionEngine = CompositionEngine();
  final GuideAnimator guideAnimator = GuideAnimator();
  final FilterRecommender filterRecommender = FilterRecommender();
  final PortraitMask portraitMask = PortraitMask();
  final FilterService filterService = FilterService();
  final LutLibrary lutLibrary = LutLibrary();
  final PhotoRepository photoRepository = PhotoRepository();
  final ExportService exportService = ExportService();

  // State
  CameraMode _mode = CameraMode.normal;
  CompositionResult? _compositionResult;
  FilterPreset? _selectedFilter;
  List<FilterPreset> _recommendedFilters = [];
  bool _isAnalyzing = false;
  bool _showFilterPanel = false;

  int _schemeIndex = 0;
  CameraDescription? _currentCamera;

  CameraMode get mode => _mode;
  CompositionResult? get compositionResult => _compositionResult;
  FilterPreset? get selectedFilter => _selectedFilter;
  List<FilterPreset> get recommendedFilters => _recommendedFilters;
  bool get isAnalyzing => _isAnalyzing;
  bool get showFilterPanel => _showFilterPanel;

  Future<void> initialize() async {
    await cameraService.initialize();
    await _startFrameProcessing();
  }

  Future<void> _startFrameProcessing() async {
    final controller = cameraService.controller;
    if (controller == null) return;

    _frameProcessor = FrameProcessor(cameraService);
    await _frameProcessor!.startProcessing(
      onFrame: _processFrame,
      skipFrames: 3,
    );
  }

  void _processFrame(CameraImage image) async {
    if (_currentCamera == null) {
      final cameras = cameraService.cameras;
      if (cameras.isNotEmpty) {
        _currentCamera = cameras[cameraService.selectedCameraIndex];
      }
    }
    if (_currentCamera == null) return;

    try {
      if (_mode == CameraMode.composition) {
        // Run all detectors in parallel
        final results = await Future.wait([
          sceneClassifier.classify(image, _currentCamera!),
          objectDetector.detectMainSubject(image, _currentCamera!),
          lineDetector.detectPoseLines(image, _currentCamera!),
        ]);

        final sceneType = results[0] as SceneType;
        final subjectRect = results[1] as Rect?;
        final lines = results[2] as List<Offset>;

        // Analyze composition
        final result = compositionEngine.analyze(
          sceneType: sceneType,
          subjectRect: subjectRect,
          lines: lines,
        );
        updateComposition(result);

        // Recommend filters based on scene
        if (_recommendedFilters.isEmpty) {
          _recommendedFilters = filterRecommender.recommend(sceneType);
        }
      }
    } catch (_) {}
  }

  setMode(CameraMode mode) {
    _mode = mode;
    if (mode == CameraMode.composition) {
      guideAnimator.show();
      _isAnalyzing = true;
      notifyListeners();
    } else {
      guideAnimator.hide();
      _compositionResult = null;
      notifyListeners();
    }
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

  void switchCompositionScheme() {
    if (_compositionResult == null) return;
    final rules = _compositionResult!.recommendedRules;
    if (rules.isEmpty) return;
    _schemeIndex = (_schemeIndex + 1) % rules.length;

    // Re-analyze with the new preferred rule
    if (_currentCamera != null) {
      _isAnalyzing = true;
      notifyListeners();
    }
  }

  void toggleFilterPanel() {
    _showFilterPanel = !_showFilterPanel;
    notifyListeners();
  }

  double get guideAlpha => 1.0;

  Future<String?> takePhoto() async {
    final xfile = await cameraService.takePhoto();
    if (xfile == null) return null;

    String path = await exportService.saveToAppStorage(
      XFile(xfile.path),
      filterName: _selectedFilter?.name,
    );

    // Apply filter if selected
    if (_selectedFilter != null && _selectedFilter!.name != 'normal') {
      final processor = lutLibrary.getFilter(_selectedFilter!);
      if (processor != null) {
        final filteredPath = path.replaceAll('.jpg', '_.jpg');
        final faceRect = _compositionResult?.subjectRect;
        const imgSize = Size(1080.0, 1920.0);
        try {
          path = await filterService.applyFilter(
            inputPath: path,
            outputPath: filteredPath,
            lutProcessor: processor,
            strength: _selectedFilter!.defaultStrength,
            faceRect: faceRect,
            imageSize: imgSize,
          );
        } catch (_) {}
      }
    }

    final photo = model.Photo(
      localPath: path,
      thumbnailPath: path,
      createdAt: DateTime.now(),
      filterName: _selectedFilter?.name,
      compositionType: _compositionResult?.sceneLabel,
    );
    await photoRepository.insert(photo);
    return path;
  }

  @override
  void dispose() {
    _frameProcessor?.dispose();
    sceneClassifier.dispose();
    objectDetector.dispose();
    faceDetector.dispose();
    lineDetector.dispose();
    cameraService.dispose();
    lutLibrary.dispose();
    photoRepository.close();
    super.dispose();
  }
}














