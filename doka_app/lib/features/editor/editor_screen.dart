import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'editor_viewmodel.dart';
import '../filter/filter_picker.dart';
import '../../models/photo.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late EditorViewModel _viewModel;
  bool _showFilterPanel = false;

  @override
  void initState() {
    super.initState();
    _viewModel = EditorViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final photo = ModalRoute.of(context)?.settings.arguments as Photo?;
      if (photo != null) _viewModel.loadPhoto(photo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('编辑'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => _viewModel.save(),
              child: const Text('保存', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<EditorViewModel>(
                builder: (context, vm, child) {
                  if (vm.imageFile == null) {
                    return const Center(child: Text('未选择照片', style: TextStyle(color: Colors.white38)));
                  }
                  return InteractiveViewer(
                    child: Image.file(vm.imageFile!, fit: BoxFit.contain),
                  );
                },
              ),
            ),
            Consumer<EditorViewModel>(
              builder: (context, vm, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[900],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSlider('亮度', vm.brightness, (v) => vm.setBrightness(v)),
                      const SizedBox(height: 8),
                      _buildSlider('对比度', vm.contrast, (v) => vm.setContrast(v)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _showFilterPanel = !_showFilterPanel),
                        icon: const Icon(Icons.filter_vintage, color: Colors.white),
                        label: const Text('滤镜', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (_showFilterPanel)
              const SizedBox(height: 100, child: FilterPicker()),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        Expanded(child: Slider(value: value, min: -1.0, max: 1.0, activeColor: Colors.white, inactiveColor: Colors.white24, onChanged: onChanged)),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.white54, fontSize: 12))),
      ],
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}



