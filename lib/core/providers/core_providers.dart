import 'package:dio/dio.dart';
import 'package:echo_nlu/services/api_service.dart';
import 'package:echo_nlu/services/image_picker_service.dart';
import 'package:echo_nlu/services/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repositories/location_repository.dart';
import '../../services/audio_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/local_storeage_service.dart';
import '../../services/permission_service.dart';

final connectivityProvider = StateProvider<bool>((ref) => true);

// Provider để format dữ liệu dùng chung
final datePreviewProvider = Provider((ref) => "dd/MM/yyyy");
final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError();
});

  final apiServiceProvider = Provider((ref) {
    final dio = ref.read(dioProvider);
    final localStorageService = ref.read(localStorageProvider);
    return ApiService(dio: dio, localStorageService: localStorageService);
  });

  final imagePickerServiceProvider = Provider((ref) {
    return  ImagePickerService();
  });

  final locationRepositoryProvider = Provider((ref) {
    final apiService = ref.read(apiServiceProvider);
    return LocationRepository(apiService: apiService);
  });


final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService(dio: Dio());
});

final audioNoteServiceProvider = Provider<AudioNoteService>((ref) {
  return AudioNoteService();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService(
    ref.read(locationServiceProvider)
  );
});