import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:echo_nlu/features/echo_detail/models/comment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import '../core/utils/api_respone.dart';
import '../features/auth/models/login_data.dart';
import '../features/echo/models/create_echo_model.dart';
import '../features/echo/models/nearby_campus_location.dart';
import '../features/echo_detail/models/echo_detail.dart';
import '../features/map/models/echo_preview.dart';
import '../repositories/echo_repository.dart';
import 'local_storeage_service.dart';

String baseUrl() {
  if (kIsWeb) return 'http://localhost:8080/api';
  if (Platform.isAndroid) return 'http://192.168.88.231:8080/api';

  return 'http://192.168.88.231:8080/api';
}

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(localStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl(),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  final refreshDio = Dio(
    BaseOptions(
      baseUrl: baseUrl(),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final isPublicApi = options.path.startsWith('/auth');
        final token = storage.token;

        if (!isPublicApi && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
      onError: (error, handler) async {
        final response = error.response;
        final requestOptions = error.requestOptions;

        final alreadyRetried = requestOptions.extra['retried'] == true;
        final isInvalidToken = _isInvalidTokenResponse(response?.data);

        if (response?.statusCode == 401 && isInvalidToken && !alreadyRetried) {
          try {
            final refreshToken = storage.refreshToken;

            if (refreshToken.isEmpty) {
              return handler.next(error);
            }

            final refreshResponse = await refreshDio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            final refreshResult = ApiResponse<LoginData>.fromJson(
              refreshResponse.data as Map<String, dynamic>,
              fromJsonT: (json) =>
                  LoginData.fromJson(json as Map<String, dynamic>),
            );

            debugPrint('Refresh token response: ${refreshResponse.data}');

            if (!refreshResult.success || refreshResult.code == StatusCode.INVALID_REFRESH_TOKEN) {

              return handler.reject(
                DioException(
                  requestOptions: requestOptions,
                  response: Response(
                    requestOptions: requestOptions,
                    statusCode: 401,
                    data: {
                      'success': false,
                      'code': StatusCode.INVALID_REFRESH_TOKEN.name,
                      'message': refreshResult.message,
                      'data': null,
                    },
                  ),
                  type: DioExceptionType.badResponse,
                ),
              );
            }

            await storage.saveToken(refreshResult.data!.token);
            await storage.saveRefreshToken(refreshResult.data!.refreshToken);

            requestOptions.extra['retried'] = true;
            requestOptions.headers['Authorization'] =
            'Bearer ${refreshResult.data!.token}';

            final retryResponse = await dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            return handler.next(error);
          }
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});

bool _isInvalidTokenResponse(dynamic data) {
  if (data is! Map<String, dynamic>) return false;

  return data['code']?.toString().toUpperCase() == StatusCode.INVALID_TOKEN.name;
}

ApiResponse<T> _handleDioError<T>(DioException e) {
  debugPrint('Dio error: ${e.message}, response: ${e.response?.data}');
  final data = e.response?.data;

  if (data is Map<String, dynamic>) {
    return ApiResponse<T>.fromJson(data);
  }

  return ApiResponse<T>(
    success: false,
    code: StatusCode.INTERNAL_SERVER_ERROR,
    message: e.message ?? 'Unknown error',
    data: null,
  );
}

class ApiService {
  final Dio dio;
  final LocalStorageService localStorageService;

  ApiService({
    required this.dio,
    required this.localStorageService,
  });

  Future<ApiResponse<LoginData>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

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
      return _handleDioError<LoginData>(e);
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
        data: {
          'fullname': fullName,
          'email': email,
          'password': password,
        },
      );

      return ApiResponse<LoginData>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => LoginData.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<LoginData>(e);
    }
  }

  Future<ApiResponse<LoginData>> refreshToken() async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {
          'refreshToken': localStorageService.refreshToken,
        },
      );

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
      return _handleDioError<LoginData>(e);
    }
  }

  Future<ApiResponse<NearbyCampusLocation?>> fetchNearbyCampusLocation(
      double latitude,
      double longitude,
      ) async {
    try {
      final response = await dio.get(
        '/campus-locations/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return ApiResponse<NearbyCampusLocation?>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) =>
            NearbyCampusLocation.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<NearbyCampusLocation?>(e);
    }
  }

  Future<ApiResponse<CreateEchoModel?>> createEcho(
      CreateEchoRequest request,
      ) async {
    try {
      final response = await dio.post(
        '/echo/create',
        data: request.toJson(),
      );

      return ApiResponse<CreateEchoModel?>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) =>
            CreateEchoModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<CreateEchoModel?>(e);
    }
  }

  Future<ApiResponse<List<EchoPreview>>> fetchEchoes(
      int page,
      int limit,
      double longitude,
      double latitude,
      ) async {
    try {
      debugPrint('Fetching echoes with longitude: $longitude, latitude: $latitude, page: $page, limit: $limit');
      final response = await dio.get(
        '/echo/echo-previews',
        queryParameters: {
          'longitude': longitude,
          'latitude': latitude,
          'page': page,
          'limit': limit,
        },
      );

      debugPrint('Raw response data: ${response.data}');

      return ApiResponse<List<EchoPreview>>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => (json as List<dynamic>)
            .map((item) => EchoPreview.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _handleDioError<List<EchoPreview>>(e);
    }
  }

  Future<ApiResponse<EchoDetail>> fetchEchoDetail(int echoId) async {
    try {
      final response = await dio.get('/echo/$echoId');

      return ApiResponse<EchoDetail>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => EchoDetail.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<EchoDetail>(e);
    }
  }

  Future<ApiResponse<Bool>> likeEchoDetail(int echoId, int userId) async {
    try {
      final response = await dio.post(
        '/echo/$echoId/likes',
        data: {'userId': userId},
      );

      return ApiResponse<Bool>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => json as Bool,
      );
    } on DioException catch (e) {
      return _handleDioError<Bool>(e);
    }
  }

  Future<ApiResponse<Comment>> addComment(
      int echoId,
      int userId,
      String content,
      ) async {
    try {
      final response = await dio.post(
        '/echo/$echoId/comments',
        data: {
          'userId': userId,
          'content': content,
        },
      );

      return ApiResponse<Comment>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => Comment.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleDioError<Comment>(e);
    }
  }

  Future<ApiResponse<List<Comment>>> fetchComments(int echoId) async {
    try {
      final response = await dio.get('/echo/$echoId/comments');

      return ApiResponse<List<Comment>>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: (json) => (json as List<dynamic>)
            .map((item) => Comment.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      return _handleDioError<List<Comment>>(e);
    }
  }

  Future<ApiResponse<String>> logout(String refreshToken) async{
    try {
      final response = await dio.post('/auth/logout',
        data: {
          'refreshToken': refreshToken,
        },
      );
      debugPrint('Logout response: ${response.data}');

      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleDioError<String>(e);
    }
  }
}