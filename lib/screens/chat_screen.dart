import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../models/chat_user.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatUser> _list = [];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: APIs.getAllMessages(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator(),
                        //     );

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          log('(${jsonEncode(data?[0].data())})');
                        // _list = data
                        //         ?.map((e) => ChatUser.fromJson(e.data()))
                        //         .toList() ??
                        //     [];
                      }

                      final _list = [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount: _list.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Text('${_list[index]}');
                            });
                      } else {
                        return const Center(
                            child: Text(
                          "Say Hii ! 👋",
                          style: TextStyle(fontSize: 22),
                        ));
                      }
                    }),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(children: [
                  Icon(CupertinoIcons.smiley),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        maxLines: null,
                        decoration: InputDecoration(),
                      ),
                    ),
                  ),
                  Icon(CupertinoIcons.photo_on_rectangle),
                  Icon(CupertinoIcons.photo_camera),
                  Padding(
                    padding: EdgeInsets.only(left: 12.0, right: 5.0),
                    child: Icon(
                      CupertinoIcons.arrow_right_circle,
                      color: Colors.lightBlue,
                      size: 25,
                    ),
                  )
                ]),
              ),
            ],
          )),
    );
  }

// topbar
  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
            color: Colors.black54,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              imageUrl: widget.user.image ?? '',
              height: MediaQuery.of(context).size.height * .05,
              width: MediaQuery.of(context).size.width * .10,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) =>
                  Icon(Icons.person_add_disabled_rounded),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name ?? '',
                  style: const TextStyle(fontSize: 17, color: Colors.black87),
                ),
                Text(
                  widget.user.about ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
