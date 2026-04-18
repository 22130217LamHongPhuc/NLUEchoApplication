import 'package:dio/dio.dart';
import 'package:echo_nlu/core/utils/api_respone.dart';
import 'package:echo_nlu/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import '../features/auth/models/login_data.dart';

abstract class AuthRepository {
  Future<ApiResponse<LoginData>> login({
    required String email,
    required String password,
  });

  Future<ApiResponse<LoginData>> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<bool> hasSession();
}


class AuthRepositoryImpl implements AuthRepository {

  final ApiService apiService;
  AuthRepositoryImpl({required this.apiService});

  @override
  Future<bool> hasSession() {
    // TODO: implement hasSession
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<LoginData>> login({required String email, required String password}) {
    final response = apiService.login(email: email, password: password);
    return response;
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<LoginData>> register({required String fullName, required String email, required String password}) {
   final response = apiService.register(fullName: fullName, email: email, password: password);
   return response;
  }

}


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AuthRepositoryImpl(apiService: apiService);
});
