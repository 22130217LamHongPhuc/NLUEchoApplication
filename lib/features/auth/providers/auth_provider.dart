import 'package:echo_nlu/features/auth/controllers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final loginControllerProvider = AutoDisposeNotifierProvider<AuthController, AuthState>(AuthController.new);
final registerControllerProvider = AutoDisposeNotifierProvider<AuthController, AuthState>(AuthController.new);