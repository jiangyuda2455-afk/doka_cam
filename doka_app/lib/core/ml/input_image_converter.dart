 import 'dart:io';
import 'dart:ui' show Size;
 import 'package:camera/camera.dart';
 import 'package:google_mlkit_commons/google_mlkit_commons.dart';
 
 class InputImageConverter {
   static InputImage? fromCameraImage(CameraImage image, CameraDescription camera) {
     final sensorOrientation = camera.sensorOrientation;
     InputImageRotation? rotation;
     if (Platform.isAndroid) {
       switch (sensorOrientation) {
         case 0:
           rotation = InputImageRotation.rotation0deg;
         case 90:
           rotation = InputImageRotation.rotation90deg;
         case 180:
           rotation = InputImageRotation.rotation180deg;
         case 270:
           rotation = InputImageRotation.rotation270deg;
         default:
           rotation = InputImageRotation.rotation0deg;
       }
       return _fromYuvImage(image, rotation);
     } else if (Platform.isIOS) {
       rotation = InputImageRotation.rotation0deg;
       return _fromBgraImage(image, rotation);
     }
     return null;
   }
 
   static InputImage _fromYuvImage(CameraImage image, InputImageRotation rotation) {
     final plane = image.planes.first;
     return InputImage.fromBytes(
       bytes: plane.bytes,
       metadata: InputImageMetadata(
         size: Size(image.width.toDouble(), image.height.toDouble()),
         rotation: rotation,
         format: InputImageFormat.nv21,
         bytesPerRow: plane.bytesPerRow,
       ),
     );
   }
 
   static InputImage _fromBgraImage(CameraImage image, InputImageRotation rotation) {
     return InputImage.fromBytes(
       bytes: image.planes[0].bytes,
       metadata: InputImageMetadata(
         size: Size(image.width.toDouble(), image.height.toDouble()),
         rotation: rotation,
         format: InputImageFormat.bgra8888,
         bytesPerRow: image.planes[0].bytesPerRow,
       ),
     );
   }
 }

