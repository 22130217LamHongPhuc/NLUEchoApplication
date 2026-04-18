

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../controllers/map_home_provider.dart';
import '../controllers/map_home_state.dart';

final userLocationProvider = StreamProvider<Position>((ref) {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Cập nhật mỗi khi di chuyển 5m
      ),
    );
});

final mapHomeProvider =
NotifierProvider<MapHomeController, MapHomeState>(MapHomeController.new);