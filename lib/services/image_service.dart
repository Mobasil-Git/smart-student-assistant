
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';


class ImageService {
  final _picker = ImagePicker();
  Future<Uint8List?> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (file == null) return null;
    return await file.readAsBytes();
  }
}
