

import 'package:echo_nlu/repositories/echo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../controllers/map_home_provider.dart';
import '../controllers/map_home_state.dart';

final userLocationProvider = StreamProvider<Position>((ref) {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
});

final mapHomeProvider = NotifierProvider.autoDispose<MapHomeController, MapHomeState>(
  () => MapHomeController(),
);