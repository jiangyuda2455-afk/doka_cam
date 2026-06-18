import 'package:camera/camera.dart';
import '../camera/camera_controller.dart';

typedef FrameCallback = void Function(CameraImage image);

class FrameProcessor {
  final CameraControllerService _cameraService;
  bool _isProcessing = false;
  int _frameSkip = 0;
  int _frameCount = 0;
  bool _running = false;

  FrameProcessor(this._cameraService);

  bool get isRunning => _running;

  Future<void> startProcessing({
    required FrameCallback onFrame,
    int skipFrames = 2,
  }) async {
    _running = true;
    _frameSkip = skipFrames;
    _frameCount = 0;
    await _cameraService.startImageStream(
      onImage: (image) {
        if (!_running) return;
        _frameCount++;
        if (_frameCount % (_frameSkip + 1) != 0) return;
        if (_isProcessing) return;
        _isProcessing = true;
        try {
          onFrame(image);
        } finally {
          _isProcessing = false;
        }
      },
    );
  }

  Future<void> stopProcessing() async {
    _running = false;
    await _cameraService.stopImageStream();
  }

  void dispose() {
    _running = false;
    stopProcessing();
  }
}
