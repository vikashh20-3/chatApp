import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

  //sender user message
  Widget _greenMessage() {
    return Container(
      child: Text(widget.message.msg.toString()),
    );
  }

  //reciever user message
  Widget _blueMessage() {
    return Container(
      child: Text(widget.message.msg.toString()),
    );
  }
}
