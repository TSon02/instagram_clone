import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  Future<String> uploadImageToStorage(
    String childName,
    File file,
    bool isPost,
  ) async {
    Reference ref = FirebaseStorage.instance.ref().child(childName).child(
          FirebaseAuth.instance.currentUser!.uid,
        );

    if (isPost) {
      final id = const Uuid().v1();

      ref = ref.child('$id.jpg');
    }

    await ref.putFile(file.absolute).whenComplete(() => null);

    final url = await ref.getDownloadURL();
    return url;
  }
}
