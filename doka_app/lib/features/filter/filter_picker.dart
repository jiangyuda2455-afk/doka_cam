import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/filter_preset.dart';
import '../../features/camera/camera_viewmodel.dart';
import '../../features/editor/editor_viewmodel.dart';

// Color swatches representing each filter's dominant look
const Map<String, Color> _filterColors = {
  'normal': Colors.white,
  'fuji_pro_400h': Color(0xFFE8C4A0),
  'fuji_classic_chrome': Color(0xFFB8A88C),
  'kodak_portra_160': Color(0xFFFFD4A0),
  'kodak_portra_400': Color(0xFFF0C090),
  'kodak_gold': Color(0xFFFFD070),
  'agfa_vista': Color(0xFF90C090),
  'bw_classic': Color(0xFF808080),
  'expired_film': Color(0xFFA09080),
};

class FilterPicker extends StatelessWidget {
  const FilterPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraVm = context.watch<CameraViewModel>();
    final editorVm = context.watch<EditorViewModel>();
    final filters = FilterPreset.builtIn;
    final selectedName = (cameraVm.selectedFilter?.name ?? editorVm.selectedFilter?.name) ?? 'normal';

    return Container(
      color: const Color(0xFF1A1A2E),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter.name == selectedName;
          final color = _filterColors[filter.name] ?? Colors.grey;
          final isRecommended = 
              cameraVm.compositionResult != null &&
              FilterPreset.sceneRecommendations.values.any((list) => list.contains(filter.name));

          return GestureDetector(
            onTap: () {
              cameraVm.selectFilter(filter);
              editorVm.selectFilter(filter);
            },
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.white : color.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withValues(alpha: 0.4), color.withValues(alpha: 0.8)],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      filter.name == 'normal' ? Icons.close : Icons.filter_vintage,
                      color: isSelected ? Colors.white : Colors.white54,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  filter.displayName,
                  style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.white60),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isRecommended && !isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('推荐', style: TextStyle(fontSize: 8, color: Colors.amber)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}


