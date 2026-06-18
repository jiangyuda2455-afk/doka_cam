import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camera_viewmodel.dart';
import 'camera_viewfinder.dart';
import 'camera_toolbar.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraViewModel? _viewModel;

  bool _permissionDenied = false;
  bool _cameraError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() {
        _permissionDenied = true;
        _errorMessage = '需要相机权限才能使用';
      });
      return;
    }
    
    final vm = CameraViewModel();
    try {
      await vm.initialize();
      _viewModel = vm;
    } catch (e) {
      _cameraError = true;
      _errorMessage = '相机初始化失败';
      vm.dispose();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text(_errorMessage, style: const TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                child: const Text('前往设置'),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text(_errorMessage, style: const TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _cameraError = false;
                  _initCamera();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_viewModel == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const CameraViewfinder(),
            Positioned(
              top: 0, left: 0, right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Consumer<CameraViewModel>(
                        builder: (context, vm, child) {
                          return Text('x',
                              style: const TextStyle(color: Colors.white, fontSize: 16));
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.grid_on, color: Colors.white70),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: const CameraToolbar(),
            ),
            Consumer<CameraViewModel>(
              builder: (context, vm, child) {
                if (vm.mode != CameraMode.composition || vm.compositionResult == null) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  top: 100, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(vm.compositionResult!.sceneLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                );
              },
            ),
            Consumer<CameraViewModel>(
              builder: (context, vm, child) {
                if (!vm.isAnalyzing) return const SizedBox.shrink();
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text('场景分析中...', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

