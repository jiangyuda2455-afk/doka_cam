import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ExportService {
  Future<String> saveToAppStorage(XFile photo, {String? filterName}) async {
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory(p.join(dir.path, 'photos'));
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = filterName != null ? '_$filterName' : '';
    final fileName = 'IMG_${timestamp}_$suffix.jpg';
    final destPath = p.join(photoDir.path, fileName);
    await File(photo.path).copy(destPath);
    return destPath;
  }

  Future<String> saveToSystemGallery(String localPath) async {
    return localPath;
  }

  Future<void> deleteLocalFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
