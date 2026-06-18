 import '../../models/composition_result.dart';
 import '../../models/filter_preset.dart';
 
 class FilterRecommender {
   List<FilterPreset> recommend(SceneType sceneType) {
     final sceneKey = _sceneTypeToString(sceneType);
     final recommended = FilterPreset.sceneRecommendations[sceneKey] ?? [];
     return FilterPreset.builtIn
         .where((f) => recommended.contains(f.name))
         .toList();
   }
 
   String _sceneTypeToString(SceneType type) {
     switch (type) {
       case SceneType.portrait:
         return 'portrait';
       case SceneType.landscape:
         return 'landscape';
       case SceneType.architecture:
         return 'architecture';
       case SceneType.food:
         return 'food';
       case SceneType.street:
         return 'street';
       case SceneType.night:
         return 'night';
       case SceneType.indoor:
         return 'indoor';
       case SceneType.unknown:
         return 'portrait';
     }
   }
 }
