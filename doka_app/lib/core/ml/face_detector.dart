import 'dart:ui' show Rect;
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'input_image_converter.dart';

class FaceDetectorService {
  late final FaceDetector _detector;

  FaceDetectorService() {
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  Future<Rect?> detectFace(CameraImage image, CameraDescription camera) async {
    final inputImage = InputImageConverter.fromCameraImage(image, camera);
    if (inputImage == null) return null;
    try {
      final faces = await _detector.processImage(inputImage);
      if (faces.isEmpty) return null;
      final face = faces.first;
      return Rect.fromLTWH(
        face.boundingBox.left.toDouble(),
        face.boundingBox.top.toDouble(),
        face.boundingBox.width.toDouble(),
        face.boundingBox.height.toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _detector.close();
}
