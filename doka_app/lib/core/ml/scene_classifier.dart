import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../../models/composition_result.dart';
import 'input_image_converter.dart';

class SceneClassifier {
  late final ImageLabeler _labeler;

  SceneClassifier() {
    _labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
  }

  Future<SceneType> classify(CameraImage image, CameraDescription camera) async {
    final inputImage = InputImageConverter.fromCameraImage(image, camera);
    if (inputImage == null) return SceneType.unknown;
    try {
      final labels = await _labeler.processImage(inputImage);
      return _mapLabelToScene(labels);
    } catch (_) {
      return SceneType.unknown;
    }
  }

  SceneType _mapLabelToScene(List<ImageLabel> labels) {
    for (final label in labels) {
      final t = label.label.toLowerCase();
      if (t.contains('person') || t.contains('portrait') || t.contains('face')) return SceneType.portrait;
      if (t.contains('landscape') || t.contains('mountain') || t.contains('beach')) return SceneType.landscape;
      if (t.contains('building') || t.contains('architecture') || t.contains('city')) return SceneType.architecture;
      if (t.contains('food') || t.contains('dish') || t.contains('fruit')) return SceneType.food;
      if (t.contains('street') || t.contains('road') || t.contains('car')) return SceneType.street;
      if (t.contains('night') || t.contains('dark')) return SceneType.night;
      if (t.contains('indoor') || t.contains('room')) return SceneType.indoor;
    }
    return SceneType.unknown;
  }

  void dispose() => _labeler.close();
}
