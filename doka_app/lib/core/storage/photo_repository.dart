 import 'dart:io';
 import 'package:path_provider/path_provider.dart';
 import 'package:sqflite/sqflite.dart';
 import 'package:path/path.dart' as p;
 import '../../models/photo.dart';
 
 class PhotoRepository {
   static Database? _database;
 
   Future<Database> get database async {
     if (_database != null) return _database!;
     _database = await _initDatabase();
     return _database!;
   }
 
   Future<Database> _initDatabase() async {
     final dir = await getApplicationDocumentsDirectory();
     final dbPath = p.join(dir.path, 'doka_photos.db');
     return await openDatabase(
       dbPath,
       version: 1,
       onCreate: (db, version) async {
         await db.execute('''
           CREATE TABLE photos (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             localPath TEXT NOT NULL,
             thumbnailPath TEXT NOT NULL,
             createdAt TEXT NOT NULL,
             latitude REAL,
             longitude REAL,
             filterName TEXT,
             compositionType TEXT
           )
         ''');
       },
     );
   }
 
   Future<int> insert(Photo photo) async {
     final db = await database;
     return await db.insert('photos', photo.toMap());
   }
 
   Future<List<Photo>> getAllPhotos() async {
     final db = await database;
     final maps = await db.query('photos', orderBy: 'createdAt DESC');
     return maps.map((m) => Photo.fromMap(m)).toList();
   }
 
   Future<Photo?> getPhoto(int id) async {
     final db = await database;
     final maps = await db.query('photos', where: 'id = ?', whereArgs: [id]);
     if (maps.isEmpty) return null;
     return Photo.fromMap(maps.first);
   }
 
   Future<int> delete(int id) async {
     final db = await database;
     final photo = await getPhoto(id);
     if (photo != null) {
       final file = File(photo.localPath);
       if (await file.exists()) await file.delete();
       final thumb = File(photo.thumbnailPath);
       if (await thumb.exists()) await thumb.delete();
     }
     return await db.delete('photos', where: 'id = ?', whereArgs: [id]);
   }
 
   Future<String> getStorageDirectory() async {
     final dir = await getApplicationDocumentsDirectory();
     final photoDir = Directory(p.join(dir.path, 'photos'));
     if (!await photoDir.exists()) {
       await photoDir.create(recursive: true);
     }
     return photoDir.path;
   }
 
   Future<void> close() async {
     final db = await database;
     await db.close();
     _database = null;
   }
 }
