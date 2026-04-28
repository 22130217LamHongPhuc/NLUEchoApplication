

import 'dart:ffi';

import 'package:echo_nlu/core/enums/echo_type.dart';
import 'package:echo_nlu/core/utils/api_respone.dart';
import 'package:echo_nlu/features/echo_detail/models/comment.dart';
import 'package:echo_nlu/features/echo_detail/models/echo_detail.dart';
import 'package:echo_nlu/features/map/models/echo_preview.dart';
import 'package:echo_nlu/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums/visibility.dart';
import '../core/providers/core_providers.dart';
import '../features/echo/models/create_echo_model.dart';


class CreateEchoRequest {
  final String title;
  final String content;
  final bool isAnonymous;
  final bool isCapsule;
  final DateTime? unlockAt;
  final EchoType echoType;
  final List<Map<String, dynamic>>? images;
  final Map<String, dynamic>? audio;
  final double latitude;
  final double longitude;
  final String locationName;
  final double gpsAccuracy;
  final Visibility visibility;

  const CreateEchoRequest({
    required this.title,
    required this.content,
    required this.isAnonymous,
    required this.isCapsule,
    this.unlockAt,
    required this.echoType,
    this.images,
    this.audio,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.gpsAccuracy,
    this.visibility = Visibility.public,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
      "anonymous": isAnonymous,
      "capsule": isCapsule,
      "unlockAt": unlockAt?.toIso8601String(),
      "echoType": echoType.name.toUpperCase(),
      "images": images,
      "audio": audio,
      "latitude": latitude,
      "longitude": longitude,
      "locationName": locationName,
      "gpsAccuracy": gpsAccuracy,
      "visibility": visibility.name.toUpperCase(),
    };
  }
}

abstract class EchoRepository {
  Future<ApiResponse<CreateEchoModel?>> createEcho(CreateEchoRequest request);
  Future<ApiResponse<List<EchoPreview>>> fetchEchoes({
    required int page,
    required int limit,
    required double longitude,
    required double latitude
  });
  Future<ApiResponse<EchoDetail>> fetchEchoDetail(int echoId);
  Future<ApiResponse<Bool>> likeEchoDetail(int echoId,int userId);

  Future<ApiResponse<Comment>> addComment(int echoId, int userId, String content);

  Future<ApiResponse<List<Comment>>> fetchComments(int echoId);

}

class EchoRepositoryImpl implements EchoRepository {
  final ApiService apiService;

  EchoRepositoryImpl({required this.apiService});

  @override
  Future<ApiResponse<CreateEchoModel?>> createEcho(
      CreateEchoRequest request) async {
    return await apiService.createEcho(request);
  }

  @override
  Future<ApiResponse<List<EchoPreview>>> fetchEchoes(
      {required int page, required int limit, required double longitude, required double latitude}) {
    return apiService.fetchEchoes(
        page,
        limit,
        longitude,
        latitude
    );
  }



  @override
  Future<ApiResponse<EchoDetail>> fetchEchoDetail(int echoId) async {
    final response = await apiService.fetchEchoDetail(echoId);
    return response;
  }

  @override
  Future<ApiResponse<Bool>> likeEchoDetail(int echoId, int userId) async{
    final response = await apiService.likeEchoDetail(echoId,userId);
    return response;
  }

  @override
  Future<ApiResponse<Comment>> addComment(int echoId, int userId, String content) {
      final response = apiService.addComment(echoId, userId, content);
      return response;
  }

  @override
  Future<ApiResponse<List<Comment>>> fetchComments(int echoId) {
    final response = apiService.fetchComments(echoId);
    return response;
  }
}

final echoRepositoryProvider = Provider<EchoRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return EchoRepositoryImpl(apiService: apiService);
});