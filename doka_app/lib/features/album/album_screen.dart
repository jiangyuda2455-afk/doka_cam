import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'album_viewmodel.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late AlbumViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AlbumViewModel();
    _viewModel.loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('相册'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<AlbumViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.photos.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 64, color: Colors.white24),
                    SizedBox(height: 16),
                    Text('还没有照片', style: TextStyle(color: Colors.white38, fontSize: 16)),
                  ],
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: vm.photos.length,
              itemBuilder: (context, index) {
                final photo = vm.photos[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/editor', arguments: photo),
                  child: Image.file(
                    File(photo.localPath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
