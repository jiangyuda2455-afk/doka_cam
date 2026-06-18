import '../../core/composition/ar_overlay_painter.dart';
import 'package:camera/camera.dart' as cam;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'camera_viewmodel.dart';


class CameraViewfinder extends StatelessWidget {
  const CameraViewfinder({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraViewModel>(
      builder: (context, vm, child) {
        final controller = vm.cameraService.controller;
        if (controller == null || !vm.cameraService.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            cam.CameraPreview(controller),
            if (vm.mode == CameraMode.composition)
              RepaintBoundary(
                child: CustomPaint(
                  painter: ArOverlayPainter(
                    result: vm.compositionResult,
                    showGuides: true,
                    animationAlpha: 1.0,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        );
      },
    );
  }
}


