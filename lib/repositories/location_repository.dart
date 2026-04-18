import 'package:echo_nlu/core/utils/api_respone.dart';
import 'package:echo_nlu/features/echo/models/nearby_campus_location.dart';
import 'package:echo_nlu/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';

class LocationRepository {
  final ApiService apiService;
  LocationRepository({required this.apiService});


  Future<ApiResponse<NearbyCampusLocation?>> fetchNearbyCampusLocation(double latitude, double longitude) async {
    return  await apiService.fetchNearbyCampusLocation(latitude, longitude);
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LocationRepository(apiService: apiService);
});