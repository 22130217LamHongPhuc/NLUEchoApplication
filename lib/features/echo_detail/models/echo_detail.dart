import 'package:echo_nlu/features/echo_detail/models/user.dart';

import 'comment.dart';
import 'media_echo.dart';

class EchoDetail {
  final int id;
  final String title;
  final String description;

  final bool anonymous;
  final bool capsule;
  final DateTime? unlockTime;

  final double distance;

  final int likes;
  final int commentsCount;

  final User user;
  final List<EchoMedia> media;

  final DateTime createdAt;

  final String locationName;

  bool isLike;

  EchoDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.anonymous,
    required this.capsule,
    this.unlockTime,
    required this.distance,
    required this.likes,
    required this.commentsCount,
    required this.user,
    required this.media,
    required this.createdAt,
    this.locationName = '',
    this.isLike = false,
  });

  factory EchoDetail.fromJson(Map<String, dynamic> json) {
    return EchoDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      anonymous: json['anonymous'] ?? false,
      capsule: json['capsule'] ?? false,
      unlockTime: json['unlockTime'] != null
          ? DateTime.parse(json['unlockTime'])
          : null,
      distance: (json['distance'] ?? 0).toDouble(),
      likes: json['likes'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      user: User.fromJson(json['user']),
      locationName: json['locationName'] ?? '',
      media: (json['media'] as List)
          .map((e) => EchoMedia.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      isLike: json['like'] ?? false,
    );
  }

 EchoDetail copyWith({
    int? id,
    String? title,
    String? description,
    bool? anonymous,
    bool? capsule,
    DateTime? unlockTime,
    double? distance,
    int? likes,
    int? commentsCount,
    User? user,
    List<EchoMedia>? media,
    DateTime? createdAt,
    String? locationName,
    bool? isLike,
  }) {
    return EchoDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      anonymous: anonymous ?? this.anonymous,
      capsule: capsule ?? this.capsule,
      unlockTime: unlockTime ?? this.unlockTime,
      distance: distance ?? this.distance,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      user: user ?? this.user,
      media: media ?? this.media,
      createdAt: createdAt ?? this.createdAt,
      locationName: locationName ?? this.locationName,
      isLike: isLike ?? this.isLike,
    );
  }
}