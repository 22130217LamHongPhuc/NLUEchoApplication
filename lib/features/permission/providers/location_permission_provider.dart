import 'package:echo_nlu/features/permission/controller/location_permission_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/location_service.dart';
final locationPermissionProvider =
AsyncNotifierProvider<LocationPermissionController, LocationStatus>(
  LocationPermissionController.new,
);