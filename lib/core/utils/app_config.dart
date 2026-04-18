import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
}