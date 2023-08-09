import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/models/user.dart' as model;

class AuthMethods {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<model.User> getUserDetails() async {
    // await Future.delayed(
    //   const Duration(seconds: 3),
    // );
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    // print(jsonEncode(snapshot.data()));
    while (snapshot.data() == null) {
      // await Future.delayed(
      //   const Duration(seconds: 1),
      // );
      snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
    }
    // print(_auth.currentUser!.uid + 'uid');
    // print((snapshot.data()));
    return model.User.fromSnap(snapshot);
  }
}
