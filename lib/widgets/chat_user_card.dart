import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

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
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ChatScreen(
                        user: widget.user,
                      )));
        },
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              imageUrl: widget.user.image ?? '',
              height: MediaQuery.of(context).size.height * .07,
              width: MediaQuery.of(context).size.width * .13,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) =>
                  Icon(Icons.person_add_disabled_rounded),
            ),
          ),
          // leading: CircleAvatar(
          //   backgroundColor: Colors.transparent,
          //   child: Icon(Icons.person_3_outlined),
          // ),
          title: Text(widget.user.name ?? ''),
          subtitle: Text(
            widget.user.about ?? '',
            maxLines: 1,
          ),
          // trailing: Text("12:43"),
          trailing: Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
                color: Colors.pink[200],
                borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}
