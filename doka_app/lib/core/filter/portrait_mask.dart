 import 'dart:ui' show Rect;
  
 class PortraitMask {
   /// Returns a mask value [0.0, 1.0] for face skin protection.
   /// 1.0 = full face protection, 0.0 = no face.
   double getSkinProtectionWeight(Rect? faceRect, double x, double y) {
     if (faceRect == null) return 0.0;
     const margin = 0.1;
     final left = (faceRect.left - margin).clamp(0.0, 1.0);
     final top = (faceRect.top - margin).clamp(0.0, 1.0);
     final right = (faceRect.left + faceRect.width + margin).clamp(0.0, 1.0);
     final bottom = (faceRect.top + faceRect.height + margin).clamp(0.0, 1.0);
     if (x >= left && x <= right && y >= top && y <= bottom) {
       return 0.6;
     }
     return 0.0;
   }
 }

