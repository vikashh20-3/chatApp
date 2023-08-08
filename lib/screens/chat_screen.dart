import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/helper/my_dat_utils.dart';
import 'package:chatapp/screens/view_profile_screen.dart';
import 'package:chatapp/widgets/msg_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _isEmoji = false;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isEmoji) {
            setState(() {
              _isEmoji = !_isEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            _list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                        }

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              // reverse: true,
                              itemCount: _list.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                // return Text('${_list[index]}');
                                return MessageCard(message: _list[index]);
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
                if (_isUploading)
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                _chatInput(),
                if (_isEmoji)
                  SizedBox(
                    height: 200,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            )),
      ),
    );
  }

  /// Chat input
  ///
  ///
  ///
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(children: [
        IconButton(
          onPressed: () {
            setState(() {
              _isEmoji = !_isEmoji;
            });
          },
          icon: Icon(CupertinoIcons.smiley),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              controller: _textController,
              maxLines: null,
              decoration: const InputDecoration(
                  hintText: 'Type Something ....',
                  hintStyle: TextStyle(color: Colors.blue),
                  border: InputBorder.none),
            ),
          ),
        ),
        IconButton(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              // Pick an image from gallery
              final List<XFile> images =
                  await picker.pickMultiImage(imageQuality: 100);
              if (images.isNotEmpty) {
                for (var i in images) {
                  setState(() {
                    _isUploading = true;
                  });
                  APIs.sendChatImage(widget.user, File(i.path));
                  setState(() {
                    _isUploading = false;
                  });
                }
              }
            },
            icon: Icon(CupertinoIcons.photo_on_rectangle)),
        IconButton(
          icon: Icon(CupertinoIcons.photo_camera),
          onPressed: () async {
            final ImagePicker picker = ImagePicker();
            // Capture a photo.
            final XFile? photo =
                await picker.pickImage(source: ImageSource.camera);

            if (photo != null) {
              setState(() {
                _isUploading = true;
              });
              // APIs.updateUserPic(File(_image!));
              APIs.sendChatImage(widget.user, File(photo.path));
              setState(() {
                _isUploading = false;
              });
            }
          },
        ),
        InkWell(
          onTap: () {
            if (_textController.text.isNotEmpty) {
              APIs.sendMessage(widget.user, _textController.text, Type.text);
              _textController.text = '';
            }
          },
          child: Padding(
            padding: EdgeInsets.only(left: 12.0, right: 5.0),
            child: Icon(
              Icons.send_outlined,
              color: Colors.lightBlue,
              size: 25,
            ),
          ),
        )
      ]),
    );
  }

// topbar
  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
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
                      imageUrl: list.isNotEmpty
                          ? list[0].image.toString()
                          : widget.user.image.toString(),
                      height: MediaQuery.of(context).size.height * .05,
                      width: MediaQuery.of(context).size.width * .10,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
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
                          list.isNotEmpty
                              ? list[0].name.toString()
                              : widget.user.name.toString(),
                          style: const TextStyle(
                              fontSize: 17, color: Colors.black87),
                        ),
                        Text(
                          list.isNotEmpty
                              ? list[0].isOnline
                                  // && list[0].isOnline!
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: list[0].lastActive.toString())
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive:
                                      widget.user.lastActive.toString()),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          )),
    );
  }
}
