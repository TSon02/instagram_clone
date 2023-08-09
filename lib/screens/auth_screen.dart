import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

import 'package:instagram_clone/widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  void submit(
    String email,
    String username,
    String password,
    File? imageFile,
    bool isLogin,
  ) async {
    UserCredential userCredential;

    // print(email);
    // print(username);
    // print(password);
    // print(imageFile);
    // print(isLogin);
    try {
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String photoUrl = await StorageMethods()
            .uploadImageToStorage('user_image', imageFile!.absolute, false);

        final time = DateTime.now().millisecondsSinceEpoch.toString();

        final user = model.User(
          email: email,
          username: username,
          uid: userCredential.user!.uid,
          photoUrl: photoUrl,
          followers: [],
          following: [],
          createAt: time,
          isOnline: false,
          lastActive: time,
          lastMessage: "Hey, I'm using Instagram",
          pushToken: '',
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set(
              user.toJson(),
            );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AuthForm(onSubmitFn: submit),
      ),
    );
  }
}
