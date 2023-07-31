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
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
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
                            onPressed: () {
                              _showBottomSheet();
                            },
                            child: const Icon(Icons.edit),
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
                  style: const TextStyle(color: Colors.black54, fontSize: 18),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .03,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    initialValue: widget.user.name ?? '',
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required field',
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .pink, // Replace this with your desired border color
                            width:
                                2.0, // Replace this with your desired border width
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    initialValue: widget.user.about ?? '',
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required field',
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors
                                .blue, // Replace this with your desired border color
                            width:
                                5.0, // Replace this with your desired border width
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      APIs.updateUserInfo();
                      const SnackBar(content: Text('Updated succesfully'));
                      log('Inside Validator');
                    }
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Update'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //bottom sheet for picking phoot
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: ((context) {
          return ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 15),
                child: Text(
                  "Add your profile picture",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * .3,
                              MediaQuery.of(context).size.height * .15)),
                      onPressed: () {},
                      child: Image.asset('images/camera.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(
                              MediaQuery.of(context).size.width * .3,
                              MediaQuery.of(context).size.height * .15)),
                      onPressed: () {},
                      child: Image.asset('images/gallery.png'))
                ],
              )
            ],
          );
        }));
  }
}
