import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'location_service.dart';

final permissionProvider = Provider<PermissionService>((ref)  {
    return PermissionService(ref.watch(locationServiceProvider));
});

final locationPermissionProvider = FutureProvider<LocationStatus>((ref) async {
    final permissionService = ref.read(permissionProvider);
    return await permissionService.checkLocationPermission();
});



class PermissionService {
  final LocationService locationService;

  PermissionService(this.locationService);

  Future<LocationStatus> checkLocationPermission() async {
    return await locationService.checkPermission();
  }

  Future<bool> checkPhotosPermission() async {
      final status = await Permission.photos.status;
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }else if(status.isPermanentlyDenied){
        final check = await openAppSettings();
        return check;
      }

      return false;
  }

  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }else if(status.isPermanentlyDenied){
      final check = await openAppSettings();
      return check;
    }

    return false;
  }

  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }else if(status.isPermanentlyDenied){
      final check = await openAppSettings();
      return check;
    }

    return false;
  }

}