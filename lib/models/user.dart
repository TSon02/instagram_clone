import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    required this.email,
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.followers,
    required this.following,
  });

  final String email;
  final String username;
  final String uid;
  final String photoUrl;
  final List followers;
  final List following;

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'uid': uid,
      'email': email,
      'photoUrl': photoUrl,
      'followers': followers,
      'following': following,
    };
  }

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      username: snapshot['username'],
      email: snapshot['email'],
      uid: snapshot['uid'],
      photoUrl: snapshot['photoUrl'],
      followers: snapshot['followers'],
      following: snapshot['following'],
    );
  }
}
