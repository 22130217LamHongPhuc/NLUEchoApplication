

import 'dart:io';

import '../../../core/enums/echo_type.dart';
import '../models/nearby_campus_location.dart';

enum CreateEchoStatus {
  initial,
  loading,
  success,
  failure,
  submitting
}

class NearbyLocationState {
  final bool isLoading;
  final String? errorMessage;
  final List<NearbyCampusLocation> locations;
  final NearbyCampusLocation? selectedLocation;

  const NearbyLocationState({
    this.isLoading = false,
    this.errorMessage,
    this.locations = const [],
    this.selectedLocation,
  });

  NearbyLocationState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<NearbyCampusLocation>? locations,
    NearbyCampusLocation? selectedLocation,
  }) {
    return NearbyLocationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      locations: locations ?? this.locations,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}


class CreateEchoState {

  final CreateEchoStatus status;
  final String? errorMessage;
  final bool isAnonymous;
  final bool isCapsule;
  final DateTime? scheduledTime;
  final EchoType echoType;
  final List<File> imageFiles;
  final File? audioFile;
  final NearbyLocationState nearbyLocationState;
  final int? durationInSeconds;

  const CreateEchoState({
    this.status = CreateEchoStatus.initial,
    this.errorMessage,
    this.isAnonymous = false,
    this.isCapsule = false,
    this.scheduledTime,
    this.echoType = EchoType.image,
    this.imageFiles = const [],
    this.audioFile,
    this.nearbyLocationState = const NearbyLocationState(),
    this.durationInSeconds,
  });


  CreateEchoState copyWith({
    CreateEchoStatus? status,
    String? errorMessage,
    bool? isAnonymous,
    bool? isCapsule,
    DateTime? scheduledTime,
    EchoType? echoType,
    List<File>? imageFiles,
    File? audioFile,
    NearbyLocationState? nearbyLocationState,
    int? durationInSeconds,
    bool clearAudio = false,
  }) {
    return CreateEchoState(
      status: status ?? this.status,
      errorMessage: errorMessage ,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isCapsule: isCapsule ?? this.isCapsule,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      echoType: echoType ?? this.echoType,
      imageFiles: imageFiles ?? this.imageFiles,
      audioFile: audioFile ?? (clearAudio ? null : this.audioFile),
      nearbyLocationState: nearbyLocationState ?? this.nearbyLocationState,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
    );
  }


}