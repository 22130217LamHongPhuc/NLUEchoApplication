import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackasia_gl/trackasia_gl.dart';

import 'map_home_state.dart';



class MapHomeController extends Notifier<MapHomeState> {
  TrackAsiaMapController? _mapController;

  static const LatLng nluCenter = LatLng(10.8711, 106.7933);

  static const double nluInsideRadiusInMeters = 1800;
  static const double nluNearRadiusInMeters = 2800;

  static const double echoUnlockRadiusInMeters = 60;

  final List<String> filters = const ['Tất cả', 'Đã mở', 'Đang khóa'];

  final List<EchoPreview> _allEchoes = const [
    EchoPreview(
      id: '1',
      title: 'Chúc bạn thi thật tốt ở thư viện nhé!',
      distanceText: '12m',
      type: EchoType.unlocked,
      likes: 128,
      comments: 32,
      location: LatLng(10.8701, 106.7889), // Cách ~38m về phía Đông Bắc
    ),
    EchoPreview(
      id: '2',
      title: 'Có một bí mật ở khu nhà A7...',
      distanceText: '34m',
      type: EchoType.locked,
      likes: 87,
      comments: 14,
      location: LatLng(10.8695, 106.7885), // Cách ~40m về phía Tây Nam
    ),
    EchoPreview(
      id: '3',
      title: 'Hẹn gặp lại chính mình ngày tốt nghiệp.',
      distanceText: 'Time Capsule',
      type: EchoType.capsule,
      likes: 211,
      comments: 41,
      location: LatLng(10.8699, 106.7883), // Cách ~45m về phía Tây Bắc
    ),
    EchoPreview(
      id: '4',
      title: 'Góc học tập lý tưởng tại Nông Lâm',
      distanceText: '15m',
      type: EchoType.unlocked,
      likes: 56,
      comments: 8,
      location: LatLng(10.8697, 106.7891), // Cách ~44m về phía Đông
    ),
  ];
  final Set<String> _addedImageKeys = {};
  final Map<String, String> _echoToSymbol = {};


  @override
  MapHomeState build() {
    Future.microtask(init);
    return const MapHomeState(isLoadingLocation: true);
  }

  List<EchoPreview> get filteredEchoes {
    final selectedFilter = state.selectedFilter;
    switch (selectedFilter) {
      case 1:
        return _allEchoes.where((e) => e.type == EchoType.unlocked).toList();
      case 2:
        return _allEchoes.where((e) => e.type == EchoType.locked).toList();
      default:
        return _allEchoes;
    }
  }



  Future<void> init() async {
    await _determineUserLocation();
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

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(user, 16.8),
    );

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


  // just you know,
  // i want to sleep but i have to finish this project before the deadline,
  // so i will do this.
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

    for (final echo in filteredEchoes) {
      final (color, icon, key) = switch (echo.type) {
        EchoType.unlocked => (Colors.lightGreen, Icons.lock_open, 'marker-unlocked'),
        EchoType.locked   => (Colors.grey, Icons.lock, 'marker-locked'),
        EchoType.capsule  => (Colors.amber, Icons.access_alarm, 'marker-capsule'),
        // TODO: Handle this case.
        EchoType.ghost => (Colors.grey, Icons.private_connectivity, 'marker-ghost'),
      };

      await addEchoMarker(
        controller,
        echo.id,
        echo.location,
        color: color,
        icon: icon,
        markerKey: key,
      );
    }
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
      Paint()..color = color.withOpacity(0.22),
    );

    // === Inner circle with glow shadow ===
    // Glow: dùng MaskFilter blur thay cho boxShadow
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()
        ..color = color.withOpacity(0.66)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Inner circle solid
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = color,
    );

    // === Icon (cùng tỉ lệ: icon size 13 / baseSize 40 = 0.325) ===
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

     final symbol =  await controller.addSymbol(
        SymbolOptions(
          geometry: position,
          iconImage: markerKey,
          iconSize: 1.2,
          iconAnchor: 'center'
        ),
      );

      _echoToSymbol[symbol.id] = echoId;
    } catch (e, st) {
      debugPrint('❌ [addEchoMarker] ERROR: $e\n$st');
    }
  }

  Future<void> addTestMarkersNearUser() async {
    debugPrint("Adding test markers near fixed location...");

    final controller = _mapController;
    if (controller == null) return;

    const user = LatLng(
      10.869937279654504,
      106.78829400171766,
    );

    debugPrint(" Fixed user: ${user.latitude}, ${user.longitude}");

    const offset = 0.00015;

    final points = [
      const LatLng(10.869937279654504 + offset, 106.78829400171766),
      const LatLng(10.869937279654504 - offset, 106.78829400171766),
      const LatLng(10.869937279654504, 106.78829400171766 + offset),
      const LatLng(10.869937279654504, 106.78829400171766 - offset),
    ];

    for (final p in points) {
      await controller.addCircle(
        CircleOptions(
          geometry: p,
          circleRadius: 8,
          circleOpacity: 0.9,
        ),
      );

      final symbol = await controller.addSymbol(
        SymbolOptions(
          geometry: p,
          iconSize: 1.8,
        ),
      );

      debugPrint("Added marker: $symbol");
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(user, 18),
    );
  }

  void _onSymbolTapped(Symbol argument) {
    final echoId = _echoToSymbol[argument.id];
    if (echoId != null) {
      debugPrint("Tapped symbol for echoId: $echoId");
      selectEchoById(echoId);
    } else {
      debugPrint(
          "Tapped symbol with id ${argument.id} has no associated echoId");
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


  void selectEchoById(String echoId) {
    if (state.accessState == NluAccessState.outsideNLU) {
      state = state.copyWith(
          errorMessage: 'Bạn cần ở trong khuôn viên NLU để tương tác với Echo.'
      );
    } else if (state.accessState == NluAccessState.nearNLU) {
      state = state.copyWith(
          errorMessage: 'Bạn đang ở gần NLU. Hãy vào sâu hơn để tương tác với Echo.'
      );
    } else {
      final echo = _allEchoes.firstWhere((e) => e.id == echoId);
      debugPrint("Selecting echo with id: $echoId, type: ${echo.type}, location: ${echo.location.latitude}, ${echo.location.longitude}");

      if (echo.type == EchoType.locked) {
        state = state.copyWith(
            errorMessage: 'Echo này đang bị khóa. Hãy thử Echo khác nhé!'
        );
      } else if (echo.type == EchoType.unlocked) {
        final userLoc = state.userLocation!;
        final distance = distanceBetweenMarker(userLoc, echo.location);
        if (distance > echoUnlockRadiusInMeters) {
          state = state.copyWith(
              errorMessage: 'Bạn cần đến gần thêm Echo khoảng ${(distance - echoUnlockRadiusInMeters).floor()}m này để tương tác.'
          );
        } else {
        state = state.copyWith(
            selectedEchoId: echoId,
            errorMessage: null,
        );
        }

      } else {
        state = state.copyWith(
          errorMessage: 'Echo này là Time Capsule, không thể mở được. Hãy thử tương tác với Echo khác nhé!'
        );
      }
    }
  }
}