import 'package:flutter/cupertino.dart';

class AuthValidator {
  static String? validateEmail(String value) {
    final email = value.trim();

    if (email.isEmpty) return 'Email không được để trống';

    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(email)) return 'Email không hợp lệ';

    return null;
  }

  static String? validatePassword(String value) {
    debugPrint('Validating password: "$value"');
    if (value.isEmpty) return 'Mật khẩu không được để trống';
    if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    return null;
  }

  static String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return 'Vui lòng nhập lại mật khẩu';
    if (password != confirmPassword) return 'Mật khẩu nhập lại không khớp';
    return null;
  }

  static String? validateFullName(String value) {
    if (value.trim().isEmpty) return 'Tên không được để trống';
    if (value.trim().length < 2) return 'Tên quá ngắn';
    return null;
  }
}