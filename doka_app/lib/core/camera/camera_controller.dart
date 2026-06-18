 import 'dart:async';
 import 'package:camera/camera.dart';
 import 'package:flutter/foundation.dart';
 
 class CameraControllerService extends ChangeNotifier {
   CameraController? _controller;
   List<CameraDescription> _cameras = [];
   int _selectedCameraIndex = 0;
   bool _isInitialized = false;
   double _currentZoom = 1.0;
   ResolutionPreset _resolution = ResolutionPreset.high;
 
   CameraController? get controller => _controller;
   bool get isInitialized => _isInitialized;
   List<CameraDescription> get cameras => _cameras;
   int get selectedCameraIndex => _selectedCameraIndex;
   double get currentZoom => _currentZoom;
   bool get isRearCamera => _cameras.isNotEmpty && 
       _cameras[_selectedCameraIndex].lensDirection == CameraLensDirection.back;
 
   Future<void> initialize() async {
     _cameras = await availableCameras();
     if (_cameras.isEmpty) return;
     await _initCamera(0);
   }
 
   Future<void> _initCamera(int index) async {
     _controller?.dispose();
     _selectedCameraIndex = index;
     _controller = CameraController(
       _cameras[index],
       _resolution,
       enableAudio: false,
       imageFormatGroup: ImageFormatGroup.nv21,
     );
     await _controller!.initialize();
     _isInitialized = true;
     notifyListeners();
   }
 
   Future<void> switchCamera() async {
     if (_cameras.length < 2) return;
     final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
     await _initCamera(newIndex);
   }
 
   Future<void> setZoom(double zoom) async {
     _currentZoom = zoom;
     await _controller?.setZoomLevel(zoom);
     notifyListeners();
   }
 
   Future<void> setResolution(ResolutionPreset preset) async {
     _resolution = preset;
     if (_isInitialized) {
       await _initCamera(_selectedCameraIndex);
     }
   }
 
   Future<XFile?> takePhoto() async {
     if (!_isInitialized || _controller == null) return null;
     try {
       return await _controller!.takePicture();
     } catch (e) {
       debugPrint('Error taking photo: $e');
       return null;
     }
   }
 
   Future<void> startImageStream({
     required void Function(CameraImage image) onImage,
   }) async {
     if (!_isInitialized || _controller == null) return;
     await _controller!.startImageStream(onImage);
   }
 
   Future<void> stopImageStream() async {
     if (_controller == null) return;
     try {
       await _controller!.stopImageStream();
     } catch (_) {}
   }
 
   @override
   void dispose() {
     _controller?.dispose();
     super.dispose();
   }
 }
