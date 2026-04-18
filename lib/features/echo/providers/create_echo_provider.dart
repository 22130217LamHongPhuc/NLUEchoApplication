import 'package:echo_nlu/core/providers/core_providers.dart';
import 'package:echo_nlu/repositories/echo_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/location_service.dart';
import '../controllers/create_echo_controller.dart';
import '../controllers/create_echo_state.dart';

final createEchoProvider = StateNotifierProvider.autoDispose<CreateEchoController, CreateEchoState>(
  (ref) => CreateEchoController(
    imagePickerService: ref.read(imagePickerServiceProvider),
    locationService: ref.read(locationServiceProvider),
    echoRepository: ref.read(echoRepositoryProvider),
    cloudinary: ref.read(cloudinaryServiceProvider),
    audioNoteService: ref.read(audioNoteServiceProvider),
    permissionService: ref.read(permissionServiceProvider),
  ),
);