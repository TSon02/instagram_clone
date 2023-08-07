import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    required this.email,
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.followers,
    required this.following,
    required this.lastMessage,
    required this.createAt,
    required this.lastActive,
    required this.isOnline,
  });

  final String email;
  final String username;
  final String uid;
  final String photoUrl;
  final String lastMessage;
  final String createAt;
  final String lastActive;
  final bool isOnline;
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
      'lastMessage': lastMessage,
      'isOnline': isOnline,
      'lastActive': lastActive,
      'createAt': createAt,
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
      lastMessage: snapshot['lastMessage'],
      isOnline: snapshot['isOnline'],
      lastActive: snapshot['lastActive'],
      createAt: snapshot['createAt'],
    );
  }
}
