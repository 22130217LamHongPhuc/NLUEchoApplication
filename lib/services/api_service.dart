import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:echo_nlu/features/echo_detail/models/comment.dart';
import 'package:echo_nlu/repositories/echo_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import '../core/utils/api_respone.dart';
import '../features/auth/models/login_data.dart';
import '../features/echo/models/create_echo_model.dart';
import '../features/echo/models/nearby_campus_location.dart';
import '../features/echo_detail/models/echo_detail.dart';
import '../features/map/models/echo_preview.dart';
import 'local_storeage_service.dart';

String baseUrl() {
  if (kIsWeb) {
    return "http://localhost:8080/api";
  }

  if (Platform.isAndroid) {
    return "https://hayden-nonpapal-twirly.ngrok-free.dev/api"; // assume emulator
  }

  return "http://192.168.1.6:8080/api"; // assume emulator
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl(),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(localStorageProvider).token;
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
    ),
  );

  return dio;
});

class ApiService {
  final Dio dio;
  final LocalStorageService localStorageService;

  ApiService({required this.dio, required this.localStorageService});

  Future<ApiResponse<LoginData>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      debugPrint("Login response: ${response.data}");

      final result = ApiResponse<LoginData>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => LoginData.fromJson(json as Map<String, dynamic>),
      );
      if (result.success && result.data != null) {
        await localStorageService.saveToken(result.data!.token);
        await localStorageService.saveRefreshToken(result.data!.refreshToken);
      }

      return result;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      return ApiResponse<LoginData>.fromJson(
        responseData.data as Map<String, dynamic>,
      );
    }
  }

  Future<ApiResponse<LoginData>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {'fullname': fullName, 'email': email, 'password': password},
      );
      final result = ApiResponse<LoginData>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => LoginData.fromJson(json as Map<String, dynamic>),
      );
      debugPrint("Register response: ${response.data}");

      return result;
    } on DioException catch (e) {
      debugPrint("Register error: ${e.response?.data ?? e.message}");
      return ApiResponse<LoginData>.fromJson(
        e.response?.data as Map<String, dynamic>,
      );
    }
  }

  Future<ApiResponse<NearbyCampusLocation?>> fetchNearbyCampusLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await dio.get(
        '/campus-locations/nearby',
        queryParameters: {'latitude': latitude, 'longitude': longitude},
      );
      final result = ApiResponse<NearbyCampusLocation>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) =>
            NearbyCampusLocation.fromJson(json as Map<String, dynamic>),
      );
      debugPrint("Fetch nearby campus location response: ${response.data}");
      return result;
    } on DioException catch (e) {
      debugPrint(
        "Fetch nearby campus location error: ${e.response?.data ?? e.message}",
      );
      return ApiResponse<NearbyCampusLocation>.fromJson(
        e.response?.data as Map<String, dynamic>,
      );
    }
  }

  Future<ApiResponse<CreateEchoModel?>> createEcho(
    CreateEchoRequest request,
  ) async {
    try {
      final response = await dio.post('/echo/create', data: request.toJson());
      final result = ApiResponse<CreateEchoModel>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) =>
            CreateEchoModel.fromJson(json as Map<String, dynamic>),
      );

      debugPrint("Fetch create echo : ${response.data}");
      return result;
    } on DioException catch (e) {
      debugPrint("Fetch create echo : ${e.response?.data ?? e.message}");
      return ApiResponse<CreateEchoModel>.fromJson(
        e.response?.data as Map<String, dynamic>,
      );
    }
  }

  Future<ApiResponse<List<EchoPreview>>> fetchEchoes(
    int page,
    int limit,
    double longitude,
    double latitude,
  ) async {
    try {
      debugPrint(
        "Fetching echoes with longitude: $longitude, latitude: $latitude, page: $page, limit: $limit",
      );
      final response = await dio.get(
        '/echo/echo-previews',
        queryParameters: {
          'longitude': longitude,
          'latitude': latitude,
          'page': page,
          'limit': limit,
        },
      );
      final result = ApiResponse<List<EchoPreview>>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) {
          final dataList = json as List<dynamic>;
          return dataList
              .map((item) => EchoPreview.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );

      debugPrint("Fetch echoes response: ${response.data}");
      return result;
    } on DioException catch (e) {
      debugPrint("Fetch echoes error: ${e.response?.data ?? e.message}");
      return ApiResponse<List<EchoPreview>>.fromJson(
        e.response?.data as Map<String, dynamic>,
      );
    }
  }

  Future<ApiResponse<EchoDetail>> fetchEchoDetail(int echoId) async {
    try {
      debugPrint("Fetching echo detail for echoId: $echoId");
      final response = await dio.get('/echo/$echoId');
      final result = ApiResponse<EchoDetail>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => EchoDetail.fromJson(json as Map<String, dynamic>),
      );

      debugPrint("Fetch echo detail response: ${response.data}");
      return result;
    } on DioException catch (e) {
      debugPrint("Fetch echo detail error: ${e.response?.data ?? e.message}");
      return ApiResponse<EchoDetail>.fromJson(
        e.response?.data as Map<String, dynamic>,
      );
    }
  }

  Future<ApiResponse<Bool>> likeEchoDetail(int echoId, int userId) async {
    try {
      debugPrint("Liking echo detail for echoId: $echoId, userId: $userId");
      final response = await dio.post(
        '/echo/$echoId/likes',
        data: {'userId': userId},
      );
      final result = ApiResponse<Bool>.fromJson(
        response.data as Map<String, dynamic>,
      );

      debugPrint("Like echo detail response: ${response.data}");
      return result;
    } on DioException catch (e) {
      debugPrint("Like echo detail error: ${e.response?.data ?? e.message}");
      return ApiResponse<Bool>.fromJson(
        e.response?.data as Map<String, dynamic>,
      );
    }
  }

  Future<ApiResponse<Comment>> addComment(
    int echoId,
    int userId,
    String content,
  ) async {
    try {
      debugPrint(
        "Adding comment to echoId: $echoId, userId: $userId, content: $content",
      );
      final response = await dio.post(
        '/echo/$echoId/comments',
        data: {'userId': userId, 'content': content},
      );
      final result = ApiResponse<Comment>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => Comment.fromJson(json as Map<String, dynamic>),
      );

      debugPrint("Add comment response: ${response.data}");
      return result;
    } on DioException catch (e) {
      debugPrint("Add comment error: ${e.response?.data ?? e.message}");
      return ApiResponse<Comment>.fromJson(
        e.response?.data as Map<String, dynamic>,
      );
    }
  }

  Future<ApiResponse<List<Comment>>> fetchComments(int echoId) async {
    try {
      debugPrint("Fetching comments for echoId: $echoId");
      final response = await dio.get('/echo/$echoId/comments');
      final result = ApiResponse<List<Comment>>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) {
          final dataList = json as List<dynamic>;
          return dataList
              .map((item) => Comment.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );

      debugPrint("Fetch comments response: ${response.data}");
      return result;
    } on DioException catch (e) {
      debugPrint("Fetch comments error: ${e.response?.data ?? e.message}");
      return ApiResponse<List<Comment>>.fromJson(
        e.response?.data as Map<String, dynamic>,
      );
    }
  }
}
