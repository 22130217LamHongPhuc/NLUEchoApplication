import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:echo_nlu/features/map/widgets/top_panel_floating.dart';
import 'package:echo_nlu/repositories/echo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackasia_gl/trackasia_gl.dart';

import '../models/echo_preview.dart';
import 'map_home_state.dart';

class MapHomeController extends Notifier<MapHomeState> {
  TrackAsiaMapController? _mapController;

  static const LatLng nluCenter = LatLng(10.8711, 106.7933);

  static const double nluInsideRadiusInMeters = 1800;
  static const double nluNearRadiusInMeters = 2800;
  static const double distanceToShowNearbyEchoesInMeters = 150;

  static const double echoUnlockRadiusInMeters = 60;
  StreamSubscription<Position>? _positionSub;

  final List<MapFilterItem> filters = [
    MapFilterItem(id: 0, label: 'Tất cả'),
    MapFilterItem(id: 1, label: 'Mới nhất'),
    MapFilterItem(id: 2, label: 'Gần tôi'),
    MapFilterItem(id: 3, label: 'Đang hot'),
  ];

  final List<EchoPreview> _allEchoes = [];
  final Set<String> _addedImageKeys = {};
  final Map<String, String> _echoToSymbol = {};
  late final EchoRepository echoRepository;

  @override
  MapHomeState build() {
    echoRepository = ref.read(echoRepositoryProvider);
    Future.microtask(init);
    return const MapHomeState(isLoadingLocation: true);

    listenUserLocation();
  }

  Future<void> init() async {
    await _determineUserLocation();
    if (state.userLocation == null) return;
    await renderEchoList();
  }

  void onMapCreated(TrackAsiaMapController controller) async {
    debugPrint("Map created, controller: $controller");
    _mapController = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  Future<void> focusToNLU() async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(nluCenter, 16.2),
    );
  }

  Future<void> focusToUser() async {
    final user = state.userLocation;
    if (user == null) return;

    await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(user, 20.0));
  }

  Future<void> _determineUserLocation() async {
    state = state.copyWith(isLoadingLocation: true);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isLoadingLocation: false,
        hasLocationPermission: false,
        accessState: NluAccessState.outsideNLU,
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        isLoadingLocation: false,
        hasLocationPermission: false,
        accessState: NluAccessState.outsideNLU,
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(pos.latitude, pos.longitude);
    final accessState = _computeNluAccessState(userLatLng);

    state = state.copyWith(
      isLoadingLocation: false,
      hasLocationPermission: true,
      userLocation: userLatLng,
      accessState: accessState,
    );
  }

  NluAccessState _computeNluAccessState(LatLng user) {
    final distance = Geolocator.distanceBetween(
      user.latitude,
      user.longitude,
      nluCenter.latitude,
      nluCenter.longitude,
    );

    if (distance <= nluInsideRadiusInMeters) {
      return NluAccessState.insideNLU;
    }
    if (distance <= nluNearRadiusInMeters) {
      return NluAccessState.nearNLU;
    }
    return NluAccessState.outsideNLU;
  }

  double distanceFromUserToEcho(EchoPreview echo) {
    final user = state.userLocation;
    if (user == null) return double.infinity;

    return Geolocator.distanceBetween(
      user.latitude,
      user.longitude,
      echo.location.latitude,
      echo.location.longitude,
    );
  }

  bool get isInsideNLU => state.accessState == NluAccessState.insideNLU;

  bool get isNearNLU => state.accessState == NluAccessState.nearNLU;

  bool get isOutsideNLU => state.accessState == NluAccessState.outsideNLU;

  bool canCreateEcho() => isInsideNLU;

  String openButtonText() {
    if (state.isLoadingLocation) return 'Đang xác định vị trí...';
    if (!state.hasLocationPermission) return 'Bật quyền vị trí để tiếp tục';
    if (isOutsideNLU) return 'Bạn cần ở trong khuôn viên NLU';
    if (isNearNLU) return 'Tiến vào gần hơn để tương tác';
    return 'Khám phá Echo này';
  }

  String locationBannerText() {
    if (state.isLoadingLocation) {
      return 'Đang xác định vị trí của bạn...';
    }
    if (!state.hasLocationPermission) {
      return 'Hãy bật quyền vị trí để app biết bạn có đang ở NLU hay không.';
    }
    switch (state.accessState) {
      case NluAccessState.insideNLU:
        return 'Bạn đang ở trong khuôn viên NLU. Có thể mở và tạo Echo gần bạn.';
      case NluAccessState.nearNLU:
        return 'Bạn đang ở gần NLU. Bạn có thể xem trước, nhưng cần vào sâu hơn để tương tác.';
      case NluAccessState.outsideNLU:
        return 'Bạn đang ngoài khu vực NLU. Hiện tại chỉ nên ở chế độ xem trước.';
    }
  }

  Future<void> renderEchoList() async {
    final controller = _mapController;
    if (controller == null) return;

    final response = await echoRepository.fetchEchoes(
      page: 0,
      limit: 20,
      longitude: state.userLocation!.longitude,
      latitude: state.userLocation!.latitude,
    );

    if (!response.success || response.data == null) {
      debugPrint("Failed to fetch echoes: ${response.message}");
      state = state.copyWith(errorMessage: response.message);
      return;
    }

    state = state.copyWith(
      echoPreviews: response.data!,
      nearbyEchoes: response.data!
          .where(
            (echo) =>
                distanceFromUserToEcho(echo) <=
                distanceToShowNearbyEchoesInMeters,
          )
          .toList(),
      nearestEcho: response.data![0],
      clearErrorMessage: true,
    );

    for (final echo in state.echoPreviews) {
      final markerConfig = _getMarkerStyle(echo);

      await addEchoMarker(
        controller,
        echo.id.toString(),
        echo.location,
        color: markerConfig.color,
        icon: markerConfig.icon,
        markerKey: markerConfig.key,
      );
    }
  }

  ({Color color, IconData icon, String key}) _getMarkerStyle(EchoPreview echo) {
    final isAnonymous = echo.anonymous == true;
    final isCapsule = echo.capsule == true;

    Color baseColor = Colors.lightGreen;
    IconData baseIcon = Icons.location_on;
    String key = 'marker-normal';

    if (isCapsule) {
      baseColor = Colors.amber;
      key = 'marker-capsule';
    } else if (isAnonymous) {
      baseColor = Colors.grey;
      key = 'marker-ghost';
    }

    return (color: baseColor, icon: baseIcon, key: key);
  }

  Future<Uint8List> _createMarkerImage({
    required Color color,
    required IconData icon,
    double size = 240,
  }) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));
    final center = Offset(size / 2, size / 2);

    final innerRadius = size * 0.167;
    final outerRadius = innerRadius * 1.63;

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()..color = color.withValues(alpha: 0.22),
    );

    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..color = color.withValues(alpha: 0.66)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Inner circle solid
    canvas.drawCircle(center, innerRadius, Paint()..color = color);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: innerRadius * 0.65, // tỉ lệ 13/40 * 2 (radius vs diameter)
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> addEchoMarker(
    TrackAsiaMapController controller,
    String echoId,
    LatLng position, {
    Color color = Colors.blueAccent,
    IconData icon = Icons.school,
    String markerKey = 'echo-marker-default',
  }) async {
    try {
      if (!_addedImageKeys.contains(markerKey)) {
        final bytes = await _createMarkerImage(color: color, icon: icon);
        await controller.addImage(markerKey, bytes);
        _addedImageKeys.add(markerKey);
      }

      final symbol = await controller.addSymbol(
        SymbolOptions(
          geometry: position,
          iconImage: markerKey,
          iconSize: 1.2,
          iconAnchor: 'center',
        ),
      );

      _echoToSymbol[symbol.id] = echoId;
    } catch (e, st) {
      debugPrint('❌ [addEchoMarker] ERROR: $e\n$st');
    }
  }

  void _onSymbolTapped(Symbol argument) {
    final echoId = _echoToSymbol[argument.id];
    if (echoId != null) {
      debugPrint("Tapped symbol for echoId: $echoId");
      selectEchoById(int.parse(echoId));
    } else {
      debugPrint(
        "Tapped symbol with id ${argument.id} has no associated echoId",
      );
    }
  }

  double distanceBetweenMarker(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  void selectEchoById(int echoId) {
    debugPrint("Selecting echo with id: $echoId");
    if (state.accessState == NluAccessState.outsideNLU) {
      state = state.copyWith(
        errorMessage: 'Bạn cần ở trong khuôn viên NLU để tương tác với Echo.',
      );
      return;
    }

    if (state.accessState == NluAccessState.nearNLU) {
      state = state.copyWith(
        errorMessage:
            'Bạn đang ở gần NLU. Hãy vào sâu hơn để tương tác với Echo.',
      );
      return;
    }

    final echo = state.echoPreviews.firstWhere((e) => e.id == echoId);

    // if (echo.capsule) {
    //   final now = DateTime.now();
    //   if (echo.unlockTime != null && echo.unlockTime!.isAfter(now)) {
    //     state = state.copyWith(
    //       errorMessage: 'Kén chưa đến thời gian nở.',
    //       selectedEchoId: null,
    //     );
    //     return;
    //   }
    // }

    final userLoc = state.userLocation;
    if (userLoc == null) {
      state = state.copyWith(
        errorMessage: 'Không thể xác định vị trí hiện tại của bạn.',
        selectedEchoId: null,
      );
      return;
    }

    final distance = distanceBetweenMarker(userLoc, echo.location);

    // if (distance > echoUnlockRadiusInMeters) {
    //   final needMore = (distance - echoUnlockRadiusInMeters).ceil();
    //   state = state.copyWith(
    //     errorMessage:
    //     'Bạn cần đến gần Echo thêm khoảng ${needMore}m để xem.',
    //     selectedEchoId: null,
    //   );
    //   return;
    // }

    state = state.copyWith(
      selectedEcho: echo,
      selectedEchoId: echoId.toString(),
      clearErrorMessage: true,
    );
  }

  void clearSelectedEcho() {
    debugPrint("Clearing selected echo");
    state = state.copyWith(
      clearSelectedEcho: true,
      clearErrorMessage: true,

      // clearGuiding: true,
    );
  }

  void selectFilter(int value) {
    state = state.copyWith(selectedFilter: value, clearErrorMessage: true);
  }

  void guideToEcho(EchoPreview echo) {
    final userLoc = state.userLocation;
    if (userLoc == null) {
      state = state.copyWith(
        errorMessage: 'Không thể xác định vị trí hiện tại của bạn.',
      );
      return;
    }

    final distance = distanceBetweenMarker(userLoc, echo.location);

    state = state.copyWith(
      selectedEcho: echo,
      selectedEchoId: echo.id.toString(),
      guidingDistance: distance,
      clearErrorMessage: true,
    );
  }

  void openNearbyEchoesSheet() {
    state = state.copyWith(
      nearbyEchoes: state.echoPreviews
          .where(
            (echo) => distanceFromUserToEcho(echo) <= nluNearRadiusInMeters,
          )
          .toList(),
      clearErrorMessage: true,
    );
  }

  onCloseTips() {
    state = state.copyWith(showTips: false);
  }

  void onShowTips() {
    debugPrint("Showing tips");
    state = state.copyWith(showTips: true);
  }

  Future<void> showGuideLine(EchoPreview echo) async {
    final user = state.userLocation!;
    if (_mapController == null) return;

    final data = buildGuideLineGeoJson(
      userLat: user.latitude,
      userLng: user.longitude,
      echoLat: echo.location.latitude,
      echoLng: echo.location.longitude,
    );

    if (!state.isGuiding) {
      await _mapController!.addSource(
        'guide-line-source',
        GeojsonSourceProperties(data: data),
      );

      await _mapController!.addLineLayer(
        'guide-line-source',
        'guide-line-layer',
        LineLayerProperties(
          lineColor: '#34D399',
          lineWidth: 4,
          lineOpacity: 0.9,
        ),
      );
    } else {
      debugPrint("Updating guide line for echo ${echo.id}");
      await _mapController!.setGeoJsonSource('guide-line-source', data);
    }

    focusToUser();

    state = state.copyWith(
      isGuiding: true,
      guidingDistance: distanceFromUserToEcho(echo),
      guidingEcho: echo,
      clearErrorMessage: true,
    );
  }

  Future<void> updateGuideLine() async {
    final echo = state.selectedEcho;
    final user = state.userLocation;

    if (echo == null || user == null || _mapController == null) return;

    final data = buildGuideLineGeoJson(
      userLat: user.latitude,
      userLng: user.longitude,
      echoLat: echo.location.latitude,
      echoLng: echo.location.longitude,
    );

    await _mapController!.setGeoJsonSource('guide-line-source', data);
  }

  Map<String, dynamic> buildGuideLineGeoJson({
    required double userLat,
    required double userLng,
    required double echoLat,
    required double echoLng,
  }) {
    return {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "geometry": {
            "type": "LineString",
            "coordinates": [
              [userLng, userLat],
              [echoLng, echoLat],
            ],
          },
          "properties": {},
        },
      ],
    };
  }

  void listenUserLocation() {
    _positionSub?.cancel();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) async {
          if (pos.accuracy > 25) return;

          final newLocation = LatLng(pos.latitude, pos.longitude);

          final oldLocation = state.userLocation;

          if (oldLocation != null) {
            final moved = Geolocator.distanceBetween(
              oldLocation.latitude,
              oldLocation.longitude,
              newLocation.latitude,
              newLocation.longitude,
            );

            if (moved < 3) return;
          }

          state = state.copyWith(
            userLocation: newLocation,
            accessState: _computeNluAccessState(newLocation),
            clearErrorMessage: true,
          );

          if (state.isGuiding && state.guidingEcho != null) {
            await updateGuideLine();
          }
        });
  }

  bool checkCondition() {
    final echo = state.selectedEcho!;
    if (echo.capsule) {
      final now = DateTime.now();
      if (echo.unlockTime != null && echo.unlockTime!.isAfter(now)) {
        state = state.copyWith(
          errorMessage: 'Kén chưa đến thời gian nở.',
          selectedEchoId: null,
        );
        return false;
      }
    }

    final distance = distanceFromUserToEcho(state.selectedEcho!);

    if (distance > echoUnlockRadiusInMeters) {
      final needMore = (distance - echoUnlockRadiusInMeters).ceil();
      state = state.copyWith(
        errorMessage: 'Bạn cần đến gần Echo thêm khoảng ${needMore}m để xem.',
        selectedEchoId: null,
      );
      return false;
    }

    return true;
  }
}
