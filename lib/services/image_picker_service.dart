import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
   final image = await  _picker.pickImage(source: ImageSource.gallery);
   if(image != null){
     return File(image.path);
   }
    return null;
  }

  Future<List<File>> pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    return images.map((image) => File(image.path)).toList();
  }
}