import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/apis.dart';
import 'package:chatapp/helper/my_dat_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/chat_user.dart';
import 'auth/login.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

_logoutUser(BuildContext context) {
  if (APIs.auth.currentUser == null) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const Login()));
  }
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //app bar
          appBar: AppBar(title: Text(widget.user.name.toString())),
          floatingActionButton: //user about
              Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined On: ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
              Text(
                  MyDateUtil.getLastMessageTime(
                      context: context,
                      time: widget.user.createdAt.toString(),
                      showYear: true),
                  style: const TextStyle(color: Colors.black54, fontSize: 15)),
            ],
          ),

          //body
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * .03),

                  //user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * .1),
                    child: CachedNetworkImage(
                      width: MediaQuery.of(context).size.height * .2,
                      height: MediaQuery.of(context).size.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image.toString(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  // for adding some space
                  SizedBox(height: MediaQuery.of(context).size.height * .03),

                  // user email label
                  Text(widget.user.email.toString(),
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16)),

                  // for adding some space
                  SizedBox(height: MediaQuery.of(context).size.height * .02),

                  //user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15),
                      ),
                      Text(widget.user.about.toString(),
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
