import 'package:flutter/material.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key, required this.user});
  final User user;
  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return ChatScreen(
                    user: widget.user,
                  );
                },
              ),
            );
          },
          child:

              // print(list[0].msg);

              // if (list.isNotEmpty) {
              //   print('object');
              //   _message = list[0];
              // }

              // if (data != null && data.first.exists) {
              //   _message = Message.fromJson(data.first.data());
              //   print(_message!.msg);
              // }

              ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.user.photoUrl),
              radius: 30,
            ),
            title: Text(widget.user.username),
            subtitle: StreamBuilder(
                stream: FirestoreMethods().getLastMessage(widget.user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('');
                  }

                  final data = snapshot.data?.docs;
                  final list =
                      data?.map((e) => Message.fromJson(e.data())).toList() ??
                          [];

                  if (list.isNotEmpty) {
                    _message = list.first;
                  }

                  print(_message == null);

                  return Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? 'image'
                            : _message!.msg!
                        : '',
                    maxLines: 1,
                  );
                }),
            trailing: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )),
    );
  }
}
