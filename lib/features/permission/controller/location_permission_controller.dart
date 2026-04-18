import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/location_service.dart';

class LocationPermissionController extends AsyncNotifier<LocationStatus> {
  @override
  Future<LocationStatus> build() async {
    return _checkPermissionInternal();
  }

  Future<LocationStatus> _checkPermissionInternal() async {
    final service = ref.read(locationServiceProvider);
    return await service.checkPermission();
  }

  Future<void> checkPermission() async {
    state = const AsyncLoading();

    try {
      final result = await _checkPermissionInternal();
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> requestPermission() async {
    state = const AsyncLoading();

    try {
      final service = ref.read(locationServiceProvider);

      await service.requestPermission();
      final result = await service.checkPermission();

      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> openLocationSettings() async {
    try {
      await ref.read(locationServiceProvider).openLocationSetting();
      await checkPermission();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> openAppSettings() async {
    try {
      await ref.read(locationServiceProvider).openAppSetting();
      await checkPermission();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}