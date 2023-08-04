import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/utils/colors.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key, required this.onSubmitFn});
  final void Function(
    String email,
    String username,
    String password,
    File? imageFile,
    bool isLogin,
  ) onSubmitFn;
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  var _isLogin = true;
  final _authFormKey = GlobalKey<FormState>();
  String _email = '';
  String _username = '';
  String _password = '';
  File? _imageFile;
  bool _isLoading = false;

  void _submit() {
    final validate = _authFormKey.currentState!.validate();
    if (!validate) {
      return;
    }

    if (_imageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take a picture'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _authFormKey.currentState!.save();
    widget.onSubmitFn(
      _email,
      _username,
      _password,
      _imageFile,
      _isLogin,
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _takePicture() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 100,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _imageFile = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: _authFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/images/ic_instagram.svg',
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (!_isLogin)
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        backgroundImage:
                            _imageFile == null ? null : FileImage(_imageFile!),
                        radius: 30,
                      ),
                      TextButton.icon(
                        onPressed: _takePicture,
                        icon: const Icon(Icons.camera),
                        label: const Text('Take a picture'),
                      )
                    ],
                  ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Email'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    const pattern =
                        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
                        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
                        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
                        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
                        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
                        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
                        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
                    final regex = RegExp(pattern);

                    if (value!.trim().isEmpty) {
                      return 'Please enter email address';
                    }

                    if (value.isNotEmpty && !regex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                  onSaved: (newValue) {
                    _email = newValue!.trim();
                  },
                ),
                if (!_isLogin)
                  const SizedBox(
                    height: 12,
                  ),
                if (!_isLogin)
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Username'),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter username';
                      }
                      if (value.trim().length < 7) {
                        return 'Must be at least 7 characters in length';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _username = newValue!.trim();
                    },
                  ),
                const SizedBox(
                  height: 12,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Password'),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    RegExp regex = RegExp(
                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                    if (value!.isEmpty) {
                      return 'Please enter password';
                    } else {
                      if (!regex.hasMatch(value)) {
                        return 'At least one upper case,one lower case,one digit,one Special character';
                      } else {
                        return null;
                      }
                    }
                  },
                  onSaved: (newValue) {
                    _password = newValue!.trim();
                  },
                  obscureText: true,
                ),
                const SizedBox(
                  height: 12,
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: blueColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _submit();
                    },
                    child: !_isLoading
                        ? Text(
                            _isLogin ? 'Log in' : 'Sign up',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          )
                        : const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.facebook,
                        color: blueColor,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Log in with Facebook',
                        style: TextStyle(
                          color: blueColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'OR',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: secondaryColor,
                      ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_isLogin ? '''Don't have an account?''' : 'Already have an account?'}  ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _authFormKey.currentState!.reset();
                        });
                      },
                      child: Text(
                        _isLogin ? 'Sign up.' : 'Log in',
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: blueColor,
                                ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
