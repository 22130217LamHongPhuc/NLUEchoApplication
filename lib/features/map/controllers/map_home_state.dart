import 'package:echo_nlu/features/map/models/echo_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:trackasia_gl/trackasia_gl.dart';


enum NluAccessState {
  insideNLU,
  nearNLU,
  outsideNLU,
}


@immutable
class MapHomeState {
  final bool isLoadingLocation;
  final LatLng? userLocation;
  final int selectedFilter;
  final String? selectedEchoId;
  final EchoPreview? selectedEcho;
  final NluAccessState accessState;
  final bool hasLocationPermission;
  final String? errorMessage;
  final List<EchoPreview> echoPreviews;
  final List<EchoPreview> nearbyEchoes;
  final EchoPreview? nearestEcho;
  final bool showTips;
  final bool isGuiding;
  final double? guidingDistance;
  final EchoPreview? guidingEcho;
  final bool? clearGuidingEcho;
  const MapHomeState({
    this.isLoadingLocation = false,
    this.userLocation,
    this.selectedFilter = 0,
    this.selectedEchoId ,
    this.selectedEcho,
    this.accessState = NluAccessState.outsideNLU,
    this.hasLocationPermission = false,
    this.errorMessage,
    this.echoPreviews = const [],
    this.nearbyEchoes = const [],
    this.nearestEcho,
    this.isGuiding = false,
    this.guidingDistance,
      this.showTips = true,
      this.guidingEcho,
      this.clearGuidingEcho,
  });

  MapHomeState copyWith({
    bool? isLoadingLocation,
    LatLng? userLocation,
    int? selectedFilter,
    String? selectedEchoId,
    EchoPreview ? selectedEcho,
    NluAccessState? accessState,
    bool? hasLocationPermission,
    bool clearUserLocation = false,
    bool clearSelectedEcho = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    List<EchoPreview>? echoPreviews,
    List<EchoPreview>? nearbyEchoes,
    EchoPreview? nearestEcho,
    bool? isGuiding,
    double? guidingDistance,
    bool ? showTips,
    EchoPreview? guidingEcho,
    bool clearGuiding = false,
  }) {
    return MapHomeState(
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      userLocation: clearUserLocation ? null : (userLocation ?? this.userLocation),
      selectedFilter: selectedFilter ?? this.selectedFilter,
      accessState: accessState ?? this.accessState,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      echoPreviews: echoPreviews ?? this.echoPreviews,
      selectedEchoId: clearSelectedEcho ? null : (selectedEchoId ?? this.selectedEchoId),
      selectedEcho: clearSelectedEcho ? null : (selectedEcho ?? this.selectedEcho),
      nearbyEchoes: nearbyEchoes ?? this.nearbyEchoes,
      nearestEcho: nearestEcho ?? this.nearestEcho,
      isGuiding: clearGuiding ? false : (isGuiding ?? this.isGuiding),
      guidingDistance: guidingDistance ?? this.guidingDistance,
      showTips: showTips ?? this.showTips,
      guidingEcho:  clearGuiding ? null : (guidingEcho ?? this.guidingEcho) ,
    );
  }
}