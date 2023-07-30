import 'package:flutter/material.dart';

import '../models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.8,
      color: Colors.white,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .03,
          vertical: MediaQuery.of(context).size.width * .01),
      // MediaQuery.of(context).size.width*.04;
      child: InkWell(
        onTap: () {},
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(Icons.person_3_outlined),
          ),
          title: Text(widget.user.name ?? ''),
          subtitle: Text(
            widget.user.about ?? '',
            maxLines: 1,
          ),
          trailing: Text("12:43"),
        ),
      ),
    );
  }
}
