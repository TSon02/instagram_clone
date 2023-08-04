import 'dart:io';

import 'package:image_picker/image_picker.dart';

pickedImage(ImageSource source, int quality, double? maxWidth) async {
  final picker = ImagePicker();

  final XFile? image = await picker.pickImage(
    source: source,
    imageQuality: quality,
    maxWidth: maxWidth,
  );

  if (image != null) {
    return File(image.path);
  } else {
    return;
  }
}
