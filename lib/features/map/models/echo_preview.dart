import 'package:echo_nlu/core/enums/echo_state.dart';
import 'package:trackasia_gl/trackasia_gl.dart';

import '../../../core/enums/echo_type.dart';

class EchoPreview {
  final int id;
  final String title;
  final EchoType type;
  final double distance;
  final bool anonymous;
  final bool capsule;
  final DateTime? unlockTime;
  final int likes;
  final int comments;
  final LatLng location;

  final EchoMode mode;

  const EchoPreview({
    required this.id,
    required this.title,
    required this.type,
    required this.distance,
    required this.likes,
    required this.comments,
    required this.anonymous,
    required this.capsule,
    this.unlockTime,
    this.mode = EchoMode.normal,
    this.location = const LatLng(0, 0),
  });

  factory EchoPreview.fromJson(Map<String, dynamic> json) {
    return EchoPreview(
      id: json['id'],
      title: json['title'],
      type: EchoType.values.firstWhere((e) => e.name.toUpperCase() == json['echoType']),
      distance: json['distance'] ?? 0.0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      location: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      anonymous: json['anonymous'] ?? false,
      capsule: json['capsule'] ?? false,
      unlockTime: json['unlockTime'] != null ? DateTime.parse(json['unlockTime']) : null,
      mode: json['mode'] != null ? EchoMode.values.firstWhere((e) => e.name.toUpperCase() == json['mode']) : EchoMode.normal,
    );
  }


}