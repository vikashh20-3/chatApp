import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Row(
      children: [
        IconButton(
          onPressed: null,
          icon: Icon(Icons.arrow_back),
          color: Colors.black54,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(55),
          child: CachedNetworkImage(
            imageUrl: widget.user.image ?? '',
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) =>
                Icon(Icons.person_add_disabled_rounded),
          ),
        ),
      ],
    );
  }
}
