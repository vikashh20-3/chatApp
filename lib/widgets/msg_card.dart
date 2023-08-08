import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:chatapp/helper/my_dat_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    bool isMe = APIs.user.uid == widget.message.fromId;
    // return APIs.user.uid == widget.message.fromId

    //     ? _greenMessage()
    //     : _blueMessage();
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  //sender user message
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageStatus(widget.message);
      log('message status updated');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? MediaQuery.of(context).size.width * .03
                : MediaQuery.of(context).size.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .04,
                vertical: MediaQuery.of(context).size.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            // child: widget.message.type == Type.text
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg.toString(),
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),

        //message time
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent.toString()),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  //reciever user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.message.read!.isNotEmpty)
          const Icon(
            Icons.done_all_sharp,
            color: Colors.blueAccent,
          ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * .45),
          child: Text(
            // widget.message.sent.toString(),
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent.toString()),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? MediaQuery.of(context).size.width * .03
                : MediaQuery.of(context).size.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .04,
                vertical: MediaQuery.of(context).size.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 152, 242, 136),
                border:
                    Border.all(color: const Color.fromARGB(255, 19, 117, 0)),
                //making borders curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg.toString(),
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),

        //message time
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        builder: ((context) {
          return ListView(shrinkWrap: true, children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * .015,
                  horizontal: MediaQuery.of(context).size.width * .4),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            if (widget.message.type == Type.text)
              _OptionItem(
                onTap: () async {
                  await Clipboard.setData(
                          ClipboardData(text: widget.message.msg.toString()))
                      .then((value) {
                    Navigator.pop(context);

                    Dialogs.showSnackBar(context, 'Text Copied');
                  });
                },
                icon: const Icon(
                  Icons.copy_rounded,
                  color: Colors.blue,
                  size: 26,
                ),
                name: 'Copy Text',
              ),
            if (widget.message.msg != Type.text)
              _OptionItem(
                onTap: () async {
                  // final imageUrl = widget.message.msg;
                  // try {
                  //   log('Image Url: ${widget.message.msg}');
                  //   await GallerySaver.saveImage('$imageUrl',
                  //           albumName: 'We Chat')
                  //       .then((success) {
                  //     //for hiding bottom sheet
                  //     Navigator.pop(context);
                  //     if (success != null && success) {
                  //       Dialogs.showSnackBar(
                  //           context, 'Image Successfully Saved!');
                  //     } else {
                  //       Navigator.pop(context);
                  //     }
                  //   });
                  // } catch (e) {
                  //   log('ErrorWhileSavingImg: $e');
                  // }
                },
                icon: Icon(
                  Icons.copy_rounded,
                  color: Colors.blue,
                  size: 26,
                ),
                name: 'Save Image',
              ),
            Divider(
              color: Colors.black54,
              indent: MediaQuery.of(context).size.width * .04,
              endIndent: MediaQuery.of(context).size.width * .04,
            ),
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                onTap: () {
                  Navigator.pop(context);
                  _showMessageUpdateDialog();
                },
                icon: const Icon(
                  Icons.mode_edit_outlined,
                  color: Colors.blue,
                  size: 26,
                ),
                name: 'Edit Message',
              ),
            if (isMe)
              _OptionItem(
                onTap: () async {
                  try {
                    await APIs.deleteMessage(widget.message).then((value) {
                      //for hiding bottom sheet
                      log('delted: ${widget.message.msg}');
                      Navigator.pop(context);
                    });
                  } catch (e) {
                    log('${e}');
                  }
                },
                icon: const Icon(
                  Icons.delete_outline_sharp,
                  color: Colors.red,
                  size: 26,
                ),
                name: 'Delete Message',
              ),
            Divider(
              color: Colors.black54,
              indent: MediaQuery.of(context).size.width * .04,
              endIndent: MediaQuery.of(context).size.width * .04,
            ),
            _OptionItem(
              onTap: () {},
              icon: const Icon(
                Icons.remove_red_eye,
                color: Colors.blue,
                size: 26,
              ),
              name:
                  'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent.toString())}',
            ),
            _OptionItem(
              onTap: () {},
              icon: const Icon(
                Icons.remove_red_eye_sharp,
                color: Colors.red,
                size: 26,
              ),
              name: widget.message.read!.isEmpty
                  ? 'Read At: Not Seen yet'
                  : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read.toString())}',
            )
          ]);
        }));
  }

//Dialog for showing update message

  void _showMessageUpdateDialog() {
    String updateMessage = widget.message.msg.toString();

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Row(
                children: [
                  Icon(Icons.message_outlined),
                  Text("Update Message")
                ],
              ),
              //content
              content: TextFormField(
                initialValue: updateMessage,
                maxLines: null,
                onChanged: (value) => updateMessage = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                      APIs.updateMessage(widget.message, updateMessage);
                    },
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .025),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '      ${name}',
              style: TextStyle(color: Colors.black, fontSize: 15),
            ))
          ],
        ),
      ),
    );
  }
}
