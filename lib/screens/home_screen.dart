import 'dart:convert';
import 'dart:developer';

import 'package:chatapp/api/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

_logoutUser(BuildContext context) {
  if (APIs.auth.currentUser == null) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const Login()));
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("We Chat   "),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))
        ],
        leading: Icon(CupertinoIcons.home),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: FloatingActionButton(
          onPressed: () async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
            log("user logouted");
            // log("\n ${Firebase}");
            _logoutUser(context);
          },
          child: Icon(Icons.add_comment_rounded),
        ),
      ),
      body: StreamBuilder(
        stream: APIs.firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          final list = [];
          if (snapshot.hasData) {
            final data = snapshot.data?.docs;
            for (var i in data!) {
              log('\n Data: ${jsonEncode(i.data())}');
              list.add(i.data()['name']);
            }
            // log('\n Data from firestor =${data}');
          }
          return ListView.builder(
              itemCount: list.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                // return ChatUserCard();
                return Text('${list[index]}');
              });
        },
      ),
    );
  }
}
