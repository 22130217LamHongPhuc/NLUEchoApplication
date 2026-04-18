import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../core/utils/app_config.dart';
class CloudinaryService {
  final Dio dio;

  CloudinaryService({required this.dio});



  Future<Map<String,dynamic>> uploadImage(File file) async {
    return _uploadFile(file, resourceType: 'image');
  }

  Future<Map<String,dynamic>> uploadAudio(File file) async {
    return _uploadFile(file, resourceType: 'video');
  }

  Future<List<Map<String,dynamic>>> uploadImages(
      CloudinaryService cloudinary,
      List<File> files,
      ) async {
    final urls = <Map<String,dynamic>>[];

    for (final file in files) {
      final url = await cloudinary.uploadImage(file);
      urls.add(url);
    }

    return urls;
  }

  Future<Map<String, dynamic>> _uploadFile(
      File file, {
        required String resourceType,
      }) async {
    final fileName = file.path.split('/').last;
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final parts = mimeType.split('/');

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType(parts[0], parts[1]),
      ),
      'upload_preset': AppConfig.uploadPreset,
    });

    try {
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/${AppConfig.cloudName}/$resourceType/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data as Map<String, dynamic>;

      return {
        "url": data['secure_url'],
        "publicId": data['public_id'],
        "mimeType": mimeType,
        "duration": data['duration'], // chỉ có nếu là audio/video
      };

    } on DioException catch (e) {
      print('statusCode: ${e.response?.statusCode}');
      print('responseData: ${e.response?.data}');
      rethrow;
    }
  }
}