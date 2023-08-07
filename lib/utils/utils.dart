import 'dart:io';

import 'package:flutter/material.dart';
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

pickedMultiImage(int quality) async {
  final picker = ImagePicker();

  final List<XFile> images = await picker.pickMultiImage(
    imageQuality: quality,
  );

  if (images.isNotEmpty) {
    return images;
  } else {
    return;
  }
}

String getFormattedTime({required BuildContext context, required String time}) {
  final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

  return TimeOfDay.fromDateTime(date).format(context);
}

String getLastActiveTime(
    {required BuildContext context, required String lastActve}) {
  final int i = int.tryParse(lastActve) ?? -1;

  if (i == -1) {
    return 'Last seen not available';
  }

  DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
  DateTime now = DateTime.now();

  String formattedTime = TimeOfDay.fromDateTime(time).format(context);

  if (time.day == now.day && time.month == now.month && time.year == now.year) {
    return 'Last seen today at $formattedTime';
  }

  if ((now.difference(time).inHours / 24).round() == 1) {
    return 'last seen yesterday at $formattedTime';
  }

  String month = _getMonth(time);

  return 'Last seen on ${time.day} $month on $formattedTime';
}

String _getMonth(DateTime time) {
  switch (time.month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';

    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sept';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
  }
  return 'NA';
}
