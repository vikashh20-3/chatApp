import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                APIs.sendChatImage(widget.user, File(image.path));
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
              // APIs.updateUserPic(File(_image!));
              APIs.sendChatImage(widget.user, File(photo.path));
              Navigator.pop(context);
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
