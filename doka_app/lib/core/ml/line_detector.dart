import 'dart:ui' show Offset;
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'input_image_converter.dart';

class LineDetectorService {
  late final PoseDetector _detector;

  LineDetectorService() {
    _detector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
      ),
    );
  }

  Future<List<Offset>> detectPoseLines(CameraImage image, CameraDescription camera) async {
    final inputImage = InputImageConverter.fromCameraImage(image, camera);
    if (inputImage == null) return [];
    try {
      final poses = await _detector.processImage(inputImage);
      if (poses.isEmpty) return [];
      final landmarks = poses.first.landmarks;
      return landmarks.values.map((l) => Offset(l.x.toDouble(), l.y.toDouble())).toList();
    } catch (_) {
      return [];
    }
  }

  void dispose() => _detector.close();
}
