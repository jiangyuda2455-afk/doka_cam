import 'dart:io';

 import 'package:flutter/material.dart';
 import '../../models/photo.dart';
 
 class AlbumGrid extends StatelessWidget {
   final List<Photo> photos;
   final void Function(Photo photo)? onTap;
 
   const AlbumGrid({super.key, required this.photos, this.onTap});
 
   @override
   Widget build(BuildContext context) {
     return GridView.builder(
       padding: const EdgeInsets.all(2),
       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
         crossAxisCount: 3,
         crossAxisSpacing: 2,
         mainAxisSpacing: 2,
       ),
       itemCount: photos.length,
       itemBuilder: (context, index) {
         final photo = photos[index];
         return GestureDetector(
           onTap: () => onTap?.call(photo),
           child: Image.file(
             File(photo.thumbnailPath),
             fit: BoxFit.cover,
             errorBuilder: (_, __, ___) =>
                 Container(color: Colors.grey[900]),
           ),
         );
       },
     );
   }
 }
 
 

