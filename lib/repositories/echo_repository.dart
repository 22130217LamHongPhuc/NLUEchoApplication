

import 'package:echo_nlu/core/enums/echo_type.dart';
import 'package:echo_nlu/core/utils/api_respone.dart';
import 'package:echo_nlu/features/echo/models/echo_model.dart';
import 'package:echo_nlu/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums/visibility.dart';
import '../core/providers/core_providers.dart';


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
  Future<ApiResponse<EchoModel?>> createEcho(CreateEchoRequest request);
}

class EchoRepositoryImpl implements EchoRepository {
  final ApiService apiService;

  EchoRepositoryImpl({required this.apiService});

  @override
  Future<ApiResponse<EchoModel?>> createEcho(CreateEchoRequest request) async {
    return await apiService.createEcho(request);
  }
}

final echoRepositoryProvider = Provider<EchoRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return EchoRepositoryImpl(apiService: apiService);
});