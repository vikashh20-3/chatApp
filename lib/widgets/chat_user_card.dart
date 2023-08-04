import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/apis.dart';
import 'package:chatapp/helper/my_dat_utils.dart';
import 'package:chatapp/models/message.dart';
import 'package:chatapp/widgets/dialogs/profile_dailog.dart';
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
  Message? _message;
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
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) {
                  _message = list[0];
                }
                return ListTile(
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(user: widget.user));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl: widget.user.image ?? '',
                          height: MediaQuery.of(context).size.height * .07,
                          width: MediaQuery.of(context).size.width * .13,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.person_add_disabled_rounded),
                        ),
                      ),
                    ),
                    title: Text(widget.user.name ?? ''),
                    subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? 'Image 🖼️'
                              : _message!.msg.toString()
                          : widget.user.about ?? '',
                      maxLines: 1,
                    ),
                    // trailing: Text("12:43"),
                    trailing: _message == null
                        ? null
                        : _message!.read!.isEmpty &&
                                _message!.fromId != APIs.user.uid
                            ? Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    color: Colors.pink[200],
                                    borderRadius: BorderRadius.circular(15)),
                              )
                            : Text(MyDateUtil.getFormattedTime(
                                context: context,
                                time: _message!.sent.toString())));
              })),
    );
  }
}
