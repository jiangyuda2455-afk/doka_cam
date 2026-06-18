import 'dart:ui' show Rect, Offset;
import 'dart:typed_data';
import '../../models/composition_result.dart';

abstract class MlEngine {
  Future<void> loadModels();
  Future<SceneType> classifyScene(CameraImageData image);
  Future<Rect?> detectSubject(CameraImageData image);
  Future<Rect?> detectFace(CameraImageData image);
  Future<List<Offset>> detectLines(CameraImageData image);
  void dispose();
}

class CameraImageData {
  final Uint8List yPlane;
  final Uint8List uvPlane;
  final int width;
  final int height;
  final int rowStride;

  const CameraImageData({
    required this.yPlane,
    required this.uvPlane,
    required this.width,
    required this.height,
    required this.rowStride,
  });
}