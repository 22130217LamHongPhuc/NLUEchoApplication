import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences prefs;

  LocalStorageService(this.prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }
  bool get isFirstLaunch =>
      prefs.getBool('first_launch') ?? true;

  String get token => prefs.getString('token') ?? '';
  String get refreshToken => prefs.getString('refreshToken') ?? '';


  Future<void> setFirstLaunchDone() async {
    await prefs.setBool('first_launch', false);
  }

  Future<void> saveToken(String token) async {
    await prefs.setString('token', token);
  }

  Future<void> saveRefreshToken(String token) async {
    await prefs.setString('refreshToken', token);
  }


  Future<void> clearSession() async {
    await prefs.remove('token');
  }

  Future<void> reset() async{
    await prefs.setBool('first_launch',true);
    await prefs.remove('token');
    await prefs.remove('refreshToken');
  }

  Future<void> resetAuth() async {
    await prefs.remove('token');
    await prefs.remove('refreshToken');
  }
}