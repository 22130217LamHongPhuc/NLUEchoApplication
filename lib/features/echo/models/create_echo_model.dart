import 'package:echo_nlu/core/enums/echo_type.dart';
import 'package:echo_nlu/core/enums/visibility.dart';

class CreateEchoModel {
  final int id;
  final String? title;
  final String? content;
  final EchoType echoType;

  final double latitude;
  final double longitude;
  final double? gpsAccuracy;
  final String? locationName;

  final int unlockRadiusM;

  final bool isAnonymous;
  final bool isCapsule;
  final DateTime? unlockAt;

  final Visibility visibility;
  final String status;

  final int likeCount;
  final int commentCount;
  final int unlockCount;

  final DateTime createdAt;
  final DateTime updatedAt;

  final List<String> mediaUrls;

  const CreateEchoModel({
    required this.id,
    this.title,
    this.content,
    required this.echoType,
    required this.latitude,
    required this.longitude,
    this.gpsAccuracy,
    this.locationName,
    required this.unlockRadiusM,
    required this.isAnonymous,
    required this.isCapsule,
    this.unlockAt,
    required this.visibility,
    required this.status,
    required this.likeCount,
    required this.commentCount,
    required this.unlockCount,
    required this.createdAt,
    required this.updatedAt,
    required this.mediaUrls,
  });

  factory CreateEchoModel.fromJson(Map<String, dynamic> json) {
    return CreateEchoModel(
      id: json['id'],

      title: json['title'],
      content: json['content'],

      echoType: EchoType.values.firstWhere(
            (e) => e.name.toUpperCase() == json['echoType'],
      ),

      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),

      gpsAccuracy: json['gpsAccuracy'] != null
          ? (json['gpsAccuracy'] as num).toDouble()
          : null,

      locationName: json['locationName'],

      unlockRadiusM: json['unlockRadiusM'],

      isAnonymous: json['anonymous'],
      isCapsule: json['capsule'],

      unlockAt: json['unlockAt'] != null
          ? DateTime.parse(json['unlockAt'])
          : null,

      visibility: Visibility.values.firstWhere(
            (e) => e.name.toUpperCase() == json['visibility'],
      ),

      status: json['status'],

      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      unlockCount: json['unlockCount'] ?? 0,

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),

      mediaUrls: (json['mediaList'] as List?)
          ?.map((e) => e['url'] as String)
          .toList() ??
          [],
    );
  }
}