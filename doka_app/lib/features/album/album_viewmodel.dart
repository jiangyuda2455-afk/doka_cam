 import 'package:flutter/material.dart';
 import '../../core/storage/photo_repository.dart';
 import '../../models/photo.dart';
 
 class AlbumViewModel extends ChangeNotifier {
   final PhotoRepository _repository = PhotoRepository();
   List<Photo> _photos = [];
   bool _isLoading = false;
 
   List<Photo> get photos => _photos;
   bool get isLoading => _isLoading;
 
   Future<void> loadPhotos() async {
     _isLoading = true;
     notifyListeners();
     _photos = await _repository.getAllPhotos();
     _isLoading = false;
     notifyListeners();
   }
 
   Future<void> deletePhoto(int id) async {
     await _repository.delete(id);
     _photos.removeWhere((p) => p.id == id);
     notifyListeners();
   }
 }
