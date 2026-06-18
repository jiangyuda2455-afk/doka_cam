  import 'camera_controller.dart';
 
 class LensSwitcher {
   final CameraControllerService _service;
 
   LensSwitcher(this._service);
 
   List<double> get availableZooms {
     final lens = _service.isRearCamera;
     return lens ? [0.5, 1.0, 2.0, 3.0] : [1.0];
   }
 
   Future<void> switchToLens(double zoom) async {
     await _service.setZoom(zoom);
   }
 
   Future<void> switchToUltraWide() async => await switchToLens(0.5);
   Future<void> switchToWide() async => await switchToLens(1.0);
   Future<void> switchToTele() async => await switchToLens(2.0);
   Future<void> switchToSuperTele() async => await switchToLens(3.0);
 }

