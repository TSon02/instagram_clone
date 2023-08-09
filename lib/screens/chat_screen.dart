import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/models/user.dart' as modeluser;
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/message_card.dart';
import 'package:flutter/foundation.dart' as foundation;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final modeluser.User user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool _showEmoji = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.user.toJson());
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              automaticallyImplyLeading: false,
              title: _appBar(),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(4.0),
                  child: Container(
                    color: primaryColor,
                    height: 0.5,
                  )),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirestoreMethods().getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data!.docs;

                          messages = data
                              .map((value) => Message.fromJson(value.data()))
                              .toList();

                          if (messages.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              physics: const BouncingScrollPhysics(),
                              controller: scrollController,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: messages[index],
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'Say Hii! 👋',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: 240,
                    child: EmojiPicker(
                      textEditingController: _textEditingController,
                      config: Config(
                        columns: 7,
                        bgColor: mobileBackgroundColor,
                        emojiSizeMax: 32 *
                            (foundation.defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? 1.30
                                : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                builder: (context) {
                  return ProfileScreen(
                    uid: widget.user.uid,
                  );
                },
              ), (route) => true);
            },
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(widget.user.photoUrl),
              ),
              title: Text(
                widget.user.username,
              ),
              subtitle: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirestoreMethods().getUserInfo(widget.user),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('');
                    }

                    final data = snapshot.data!.docs;

                    final list =
                        data.map((e) => modeluser.User.fromSnap(e)).toList();

                    return Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : getLastActiveTime(
                                  context: context,
                                  lastActve: list[0].lastActive)
                          : getLastActiveTime(
                              context: context,
                              lastActve: widget.user.lastActive),
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(Icons.emoji_emotions),
                    color: Colors.blueAccent,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type Something...',
                      ),
                      onTap: () {
                        if (_showEmoji) {
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                        }
                      },
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      // final fileImage =
                      //     await pickedImage(ImageSource.gallery, 70, 300);

                      // if (fileImage != null) {
                      //   await FirestoreMethods()
                      //       .sendChatImage(widget.user, fileImage);
                      // }

                      final images = await pickedMultiImage(70);

                      for (var image in images) {
                        setState(() {
                          _isLoading = true;
                        });
                        await FirestoreMethods()
                            .sendChatImage(widget.user, File(image.path));

                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    color: Colors.blueAccent,
                    icon: const Icon(Icons.image),
                  ),
                  IconButton(
                    color: Colors.blueAccent,
                    onPressed: () async {
                      final fileImage =
                          await pickedImage(ImageSource.camera, 70, 300);

                      if (fileImage != null) {
                        setState(() {
                          _isLoading = true;
                        });
                        await FirestoreMethods()
                            .sendChatImage(widget.user, fileImage);

                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.camera),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                FirestoreMethods().sendMessage(
                  widget.user,
                  _textEditingController.text.trim(),
                  Type.text,
                );

                _textEditingController.text = '';
              }
            },
            color: Colors.green,
            padding:
                const EdgeInsets.only(top: 15, left: 15, bottom: 15, right: 10),
            shape: const CircleBorder(),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
