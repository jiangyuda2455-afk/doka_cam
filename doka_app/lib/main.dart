import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PLATFORM ERROR: $error');
    return true;
  };
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DokaApp());
}