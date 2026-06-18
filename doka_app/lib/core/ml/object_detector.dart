import 'dart:ui' show Rect;
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'input_image_converter.dart';

class ObjectDetectorService {
  late final ObjectDetector _detector;

  ObjectDetectorService() {
    _detector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.stream,
        multipleObjects: false,
        classifyObjects: true,
      ),
    );
  }

  Future<Rect?> detectMainSubject(CameraImage image, CameraDescription camera) async {
    final inputImage = InputImageConverter.fromCameraImage(image, camera);
    if (inputImage == null) return null;
    try {
      final objects = await _detector.processImage(inputImage);
      if (objects.isEmpty) return null;
      final obj = objects.first;
      return Rect.fromLTWH(
        obj.boundingBox.left.toDouble(),
        obj.boundingBox.top.toDouble(),
        obj.boundingBox.width.toDouble(),
        obj.boundingBox.height.toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() => _detector.close();
}

