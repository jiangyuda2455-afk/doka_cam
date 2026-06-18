 import 'package:flutter/material.dart';
 
 class ProcessingIndicator extends StatelessWidget {
   final String? message;
   final double size;
 
   const ProcessingIndicator({
     super.key,
     this.message,
     this.size = 40,
   });
 
   @override
   Widget build(BuildContext context) {
     return Column(
       mainAxisSize: MainAxisSize.min,
       children: [
         SizedBox(
           width: size,
           height: size,
           child: const CircularProgressIndicator(
             color: Colors.white,
             strokeWidth: 3,
           ),
         ),
         if (message != null) ...[
           const SizedBox(height: 12),
           Text(
             message!,
             style: const TextStyle(
               color: Colors.white70,
               fontSize: 13,
             ),
           ),
         ],
       ],
     );
   }
 }
