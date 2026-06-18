import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';
import 'features/camera/camera_screen.dart';
import 'features/album/album_screen.dart';

class DokaApp extends StatelessWidget {
  const DokaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doka Cam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/camera': (context) => const CameraScreen(),
        '/album': (context) => const AlbumScreen(),
      },
    );
  }
}