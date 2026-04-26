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
  final List<Comment> comments;

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
    required this.comments,
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
      comments: (json['comments'] as List)
          .map((e) => Comment.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      isLike: json['like'] ?? false,
    );
  }

  EchoDetail copyWith({required bool isLiked, required likeCount}) {
    return EchoDetail(
      id: id,
      title: title,
      description: description,
      anonymous: anonymous,
      capsule: capsule,
      unlockTime: unlockTime,
      distance: distance,
      likes: likeCount,
      commentsCount: commentsCount,
      user: user,
      media: media,
      comments: comments,
      createdAt: createdAt,
      locationName: locationName,
      isLike: isLiked,
    );
  }
}