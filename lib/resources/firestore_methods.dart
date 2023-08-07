import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/message.dart' as modelmessage;
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';
import 'package:instagram_clone/models/user.dart' as modeluser;

class FirestoreMethods {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _firestorage = FirebaseStorage.instance;

  Future<String> uploadPost(
    File file,
    String description,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = 'some error';
    try {
      final photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      final postId = const Uuid().v1();

      final post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> postComment(String postId, String text, String uid,
      String username, String profPic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();

        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(
          {
            'commentId': commentId,
            'text': text,
            'uid': uid,
            'username': username,
            'profPic': profPic,
            'datePublished': DateTime.now(),
          },
        );
      } else {
        print('Text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();

      List following = (snap.data() as Map<dynamic, dynamic>)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove(
            [uid],
          ),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion(
            [uid],
          ),
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: _auth.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(modeluser.User user) {
    return _firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .snapshots();
  }

  Future<void> updateActiveStatus(bool isOnline) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  String getConversationID(String id) {
    final userId = _auth.currentUser!.uid;
    return userId.hashCode <= id.hashCode ? '${userId}_$id' : '${id}_$userId';
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      modeluser.User user) {
    return _firestore
        .collection('chats/${getConversationID(user.uid)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(
      modeluser.User user, String msg, modelmessage.Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final currentUser = _auth.currentUser;

    final modelmessage.Message message = modelmessage.Message(
      toId: user.uid,
      msg: msg,
      read: '',
      type: type,
      fromId: currentUser!.uid,
      sent: time,
    );

    final ref =
        _firestore.collection('chats/${getConversationID(user.uid)}/messages/');
    await ref.doc(time).set(message.toJson());
    // return;
  }

  Future<void> updateMessageReadStatus(modelmessage.Message message) async {
    _firestore
        .collection('chats/${getConversationID(message.fromId!)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      modeluser.User user) {
    return _firestore
        .collection('chats/${getConversationID(user.uid)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  Future<void> sendChatImage(modeluser.User user, File file) async {
    Reference ref = _firestorage.ref().child(
        'images/${getConversationID(user.uid)}/${DateTime.now().millisecondsSinceEpoch}');

    await ref.putFile(file.absolute).whenComplete(() => null);

    final imageUrl = await ref.getDownloadURL();

    await sendMessage(user, imageUrl, modelmessage.Type.image);
  }
}
