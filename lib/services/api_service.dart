import 'dart:io';

import 'package:dio/dio.dart';
import 'package:echo_nlu/features/echo/models/echo_model.dart';
import 'package:echo_nlu/repositories/echo_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import '../core/utils/api_respone.dart';
import '../features/auth/models/login_data.dart';
import '../features/echo/models/nearby_campus_location.dart';
import 'local_storeage_service.dart';

String baseUrl() {
  if (kIsWeb) {
    return "http://localhost:8080/api";
  }

  if (Platform.isAndroid) {
    return "http://192.168.100.139:8080/api"; // assume emulator
  }

  return "http://localhost:8080/api";
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl(),
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref.read(localStorageProvider).token;
      options.headers['Authorization'] = 'Bearer ${token ?? ''}';
      return handler.next(options);
    },
  ));

  return dio;
});

class ApiService {
  final Dio dio;
  final LocalStorageService localStorageService;
  ApiService({required this.dio,required this.localStorageService});

  Future<ApiResponse<LoginData>> login({required String email, required String password}) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      debugPrint("Login response: ${response.data}");

      final result = ApiResponse<LoginData>.fromJson(
              response.data as Map<String, dynamic>,
            (json) => LoginData.fromJson(json as Map<String, dynamic>),
      );
      if(result.success && result.data != null) {
        await localStorageService.saveToken(result.data!.token);
        await localStorageService.saveRefreshToken(result.data!.refreshToken);
      }

      return result;
    } on DioError catch (e) {
      final responseData = e.response?.data;
      return  ApiResponse<LoginData>.fromJson(
        responseData.data as Map<String, dynamic>,
            (json) => LoginData.fromJson(json as Map<String, dynamic>),
      );
    }

  }

  Future<ApiResponse<LoginData>> register({required String fullName, required String email, required String password}) async {
    try {
      final response = await dio.post('/auth/register', data: {
        'fullname': fullName,
        'email': email,
        'password': password,
      });
      final result = ApiResponse<LoginData>.fromJson(
        response.data as Map<String, dynamic>,
            (json) => LoginData.fromJson(json as Map<String, dynamic>),
      );
      debugPrint("Register response: ${response.data}");


      return result;
    } on DioError catch (e) {
      debugPrint("Register error: ${e.response?.data ?? e.message}");
      return ApiResponse<LoginData>.fromJson(
        e.response?.data as Map<String, dynamic>,
            (json) => LoginData.fromJson(json as Map<String, dynamic>),
      );
    }
  }

  Future<ApiResponse<NearbyCampusLocation?>> fetchNearbyCampusLocation(double latitude, double longitude) async {
    try {
      final response = await dio.get('/campus-locations/nearby', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      });
      final result = ApiResponse<NearbyCampusLocation>.fromJson(
        response.data as Map<String, dynamic>,
              (json) => NearbyCampusLocation.fromJson(json as Map<String, dynamic>),
      );
      debugPrint("Fetch nearby campus location response: ${response.data}");
      return result;
    } on DioError catch (e) {
      debugPrint("Fetch nearby campus location error: ${e.response?.data ?? e.message}");
      return ApiResponse<NearbyCampusLocation>.fromJson(
        e.response?.data as Map<String, dynamic>,
            (json) => NearbyCampusLocation.fromJson(json as Map<String, dynamic>),
      );
    }
  }

  Future<ApiResponse<EchoModel?>> createEcho(CreateEchoRequest request) async {

    try {
      final response = await dio.post('/echo/create',
      data: request.toJson(),
      );
      final result = ApiResponse<EchoModel>.fromJson(
        response.data as Map<String, dynamic>,
            (json) => EchoModel.fromJson(json as Map<String, dynamic>),
      );

      debugPrint("Fetch create echo : ${response.data}");
      return result;
    } on DioError catch (e) {
      debugPrint("Fetch create echo : ${e.response?.data ?? e.message}");
      return ApiResponse<EchoModel>.fromJson(
        e.response?.data as Map<String, dynamic>,
            (json) => EchoModel.fromJson(json as Map<String, dynamic>),
      );
      debugPrint("Fetch nearby campus location response: ${e.response?.data}");
    }
  }
}