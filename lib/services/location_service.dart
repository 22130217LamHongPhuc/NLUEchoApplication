import 'package:echo_nlu/features/echo/models/nearby_campus_location.dart';
import 'package:echo_nlu/repositories/location_repository.dart' hide locationRepositoryProvider;
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../core/providers/core_providers.dart';

enum LocationStatus {
  granted,
  denied,
  serviceDisabled, deniedForever,
}

class LocationService {

  final LocationRepository locationRepository;

  LocationService({required this.locationRepository});

  Future<LocationStatus> checkPermission() async {
    debugPrint(' [LocationService] CHECK START');

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint(' Service enabled: $serviceEnabled');

    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('Current permission: $permission');

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
      debugPrint('Request result: $permission');
    }

    return switch (permission) {
      LocationPermission.denied => LocationStatus.denied,
      LocationPermission.deniedForever => LocationStatus.deniedForever,
      LocationPermission.always => LocationStatus.granted,
      LocationPermission.whileInUse => LocationStatus.granted,
      _ => LocationStatus.denied,
    };
  }

  Future<LocationStatus> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();


    if (permission == LocationPermission.denied) {
      debugPrint('🔴 User denied');
      return LocationStatus.denied;
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('🔴 User denied FOREVER');
      return LocationStatus.deniedForever;
    }

    debugPrint('🟢 Permission granted');
    return LocationStatus.granted;
  }

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition();
  }


  Stream<Position> get locationStream =>
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

  Future<void> openLocationSetting() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSetting() async {
    await Geolocator.openAppSettings();
  }

  Future<List<NearbyCampusLocation>> getNearbyCampusLocations() async {
    final position = await getCurrentLocation();
    final response = await locationRepository.fetchNearbyCampusLocation(
        position.latitude, position.longitude);
    if (response.success && response.data != null) {
      return [response.data!];
    }
    return [];

}

}

final locationServiceProvider = Provider((ref) => LocationService(
    locationRepository: ref.read(locationRepositoryProvider)
));
