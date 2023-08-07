import 'package:flutter/material.dart';
import 'package:instagram_clone/models/message.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Provider.of<UserProvider>(context).getUser.uid ==
            widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  Widget _blueMessage() {
    if (widget.message.read!.isEmpty) {
      FirestoreMethods().updateMessageReadStatus(widget.message);
      log('succesful');
    }

    return Row(
      children: [
        Flexible(
          child: Container(
            padding: widget.message.type == Type.text
                ? const EdgeInsets.all(18)
                : const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 14, 131, 182),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              border: Border.all(width: 1, color: primaryColor),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      '${widget.message.msg}',
                      // width: 200,
                      // height: 200,
                    ),
                  ),
          ),
        ),
        Text(
          getFormattedTime(context: context, time: widget.message.sent!),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            if (widget.message.read!.isNotEmpty)
              const Icon(Icons.done_all_rounded),
            const SizedBox(
              width: 4,
            ),
            Text(
              getFormattedTime(context: context, time: widget.message.sent!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: widget.message.type == Type.text
                ? const EdgeInsets.all(18)
                : const EdgeInsets.all(14),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 96, 149, 36),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              border: Border.all(width: 1, color: primaryColor),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      '${widget.message.msg}',
                      // width: 200,
                      // height: 200,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
