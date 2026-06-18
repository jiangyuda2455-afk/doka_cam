 import 'dart:io';
  
 class LutLoader {
   static const int _lutSize = 64;
 
   Future<List<double>?> loadCubeFile(String path) async {
     try {
       final file = File(path);
       if (!await file.exists()) return null;
       final lines = await file.readAsLines();
       return _parseCubeLines(lines);
     } catch (e) {
       return null;
     }
   }
 
   List<double>? _parseCubeLines(List<String> lines) {
     final data = <double>[];
     bool inLut = false;
     for (final line in lines) {
       final trimmed = line.trim();
       if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
       if (trimmed.startsWith('LUT_3D_SIZE')) {
         inLut = true;
         continue;
       }
       if (!inLut) continue;
       final parts = trimmed.split(RegExp(r'\s+'));
       if (parts.length == 3) {
         data.addAll(parts.map((p) => double.tryParse(p) ?? 0.0));
       }
     }
     return data.length == _lutSize * _lutSize * _lutSize * 3 ? data : null;
   }
 
   static int get lutSize => _lutSize;
 }
