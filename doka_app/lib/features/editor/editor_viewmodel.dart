import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/lut/lut_library.dart';
import '../../models/photo.dart';
import '../../models/filter_preset.dart';

import '../../core/storage/frame_overlay_service.dart';

class EditorViewModel extends ChangeNotifier {
  final LutLibrary _lutLibrary = LutLibrary();

  Photo? _photo;
  File? _imageFile;
  FilterPreset? _selectedFilter;
  double _brightness = 0.0;
  double _contrast = 0.0;

  Photo? get photo => _photo;
  File? get imageFile => _imageFile;
  FilterPreset? get selectedFilter => _selectedFilter;
  double get brightness => _brightness;
  double get contrast => _contrast;

  void loadPhoto(Photo photo) {
    _photo = photo;
    _imageFile = File(photo.localPath);
    notifyListeners();
  }

  void selectFilter(FilterPreset filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setBrightness(double value) {
    _brightness = value;
    notifyListeners();
  }

  void setContrast(double value) {
    _contrast = value;
    notifyListeners();
  }

    final FrameOverlayService _frameService = FrameOverlayService();
  FrameStyle? _selectedFrame;
  FrameStyle? get selectedFrame => _selectedFrame;

  void selectFrame(FrameStyle style) {
    _selectedFrame = _selectedFrame == style ? null : style;
    notifyListeners();
  }

  Future<void> save() async {
    if (_photo == null) return;
    // Apply frame overlay if selected
    if (_selectedFrame != null) {
      try {
        final outputPath = _photo!.localPath.replaceAll('.jpg', '_framed.jpg');
        await _frameService.applyFrame(
          inputPath: _photo!.localPath,
          outputPath: outputPath,
          style: _selectedFrame!,
        );
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _lutLibrary.dispose();
    super.dispose();
  }
}


