   import 'package:flutter/material.dart';
   import '../../models/filter_preset.dart';
 
 class FilterPreview extends StatelessWidget {
   final FilterPreset filter;
   final String? imagePath;
   final double size;
 
   const FilterPreview({
     super.key,
     required this.filter,
     this.imagePath,
     this.size = 64,
   });
 
   @override
   Widget build(BuildContext context) {
     return Container(
       width: size,
       height: size,
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(8),
         color: Colors.grey[850],
       ),
       child: Center(
         child: Text(
           filter.displayName,
           style: const TextStyle(color: Colors.white38, fontSize: 10),
           textAlign: TextAlign.center,
         ),
       ),
     );
   }
 }
