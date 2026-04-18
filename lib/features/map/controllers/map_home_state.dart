import 'package:flutter/foundation.dart';
import 'package:trackasia_gl/trackasia_gl.dart';

enum EchoType { unlocked, locked, capsule, ghost }

enum NluAccessState {
  insideNLU,
  nearNLU,
  outsideNLU,
}

class EchoPreview {
  final String id;
  final String title;
  final String distanceText;
  final EchoType type;
  final int likes;
  final int comments;
  final LatLng location;

  const EchoPreview({
    required this.id,
    required this.title,
    required this.distanceText,
    required this.type,
    required this.likes,
    required this.comments,
    required this.location,
  });
}

@immutable
class MapHomeState {
  final bool isLoadingLocation;
  final LatLng? userLocation;
  final int selectedFilter;
  final String? selectedEchoId;
  final NluAccessState accessState;
  final bool hasLocationPermission;
  final String? errorMessage;



  const MapHomeState({
    this.isLoadingLocation = false,
    this.userLocation,
    this.selectedFilter = 0,
    this.selectedEchoId ,
    this.accessState = NluAccessState.outsideNLU,
    this.hasLocationPermission = false,
    this.errorMessage,
  });

  MapHomeState copyWith({
    bool? isLoadingLocation,
    LatLng? userLocation,
    int? selectedFilter,
    String? selectedEchoId,
    NluAccessState? accessState,
    bool? hasLocationPermission,
    bool clearUserLocation = false,
    String? errorMessage,
  }) {
    return MapHomeState(
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      userLocation: clearUserLocation ? null : (userLocation ?? this.userLocation),
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedEchoId: selectedEchoId ?? this.selectedEchoId,
      accessState: accessState ?? this.accessState,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}