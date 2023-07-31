import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/api/apis.dart';
import 'package:chatapp/helper/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/chat_user.dart';
import 'auth/login.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

_logoutUser(BuildContext context) {
  if (APIs.auth.currentUser == null) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const Login()));
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Screen"),
        // actions: [
        //   IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        //   IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
        // ],
        // leading: Icon(CupertinoIcons.home),
      ),
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width * .25,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: FloatingActionButton(
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then((value) async => {
                    await GoogleSignIn().signOut().then((value) {
                      Navigator.pop(context);
                      Navigator.pop(context);

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const Login()));
                    })
                  });
              log("user logouted");
              // log("\n ${Firebase}");
              _logoutUser(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_sharp),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("LogOut"),
                )
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .3,
              ),
              Stack(
                children: [
                  ClipRRect(
                    // borderRadius: BorderRadius.circular(65),
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * .1),
                    child: CachedNetworkImage(
                      height: MediaQuery.of(context).size.height * .2,
                      width: MediaQuery.of(context).size.width * .45,
                      imageUrl: widget.user.image ?? '',
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person_add_disabled_rounded),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: -4,
                    child: MaterialButton(
                      onPressed: () {},
                      child: Icon(Icons.edit),
                      shape: const CircleBorder(),
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ],
          ),
          Text(
            widget.user.email ?? '',
            style: TextStyle(color: Colors.black54, fontSize: 18),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .03,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              initialValue: widget.user.name ?? '',
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors
                          .pink, // Replace this with your desired border color
                      width: 2.0, // Replace this with your desired border width
                    ),
                  ),
                  label: const Text('Name'),
                  hintText: 'eg Vikash Yadav',
                  prefixIcon: const Icon(
                    Icons.person_2_outlined,
                    color: Colors.pink,
                  ),
                  iconColor: Colors.pink[50]),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .02,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              initialValue: widget.user.about ?? '',
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors
                          .blue, // Replace this with your desired border color
                      width: 5.0, // Replace this with your desired border width
                    ),
                  ),
                  label: const Text('About'),
                  hintText: 'eg Hey There I\'m using WeChat',
                  prefixIcon: const Icon(
                    Icons.info_outline,
                    color: Colors.red,
                  ),
                  iconColor: Colors.pink[50]),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * .03,
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.edit_rounded),
            label: Text('Update'),
          )
        ],
      ),
    );
  }
}
