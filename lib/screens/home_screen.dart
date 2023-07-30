import 'dart:developer';

import 'package:chatapp/api/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
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
  List<ChatUser> list = [];
  // List list = [];
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
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );

              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                    [];
            }

            if (list.isNotEmpty) {
              return ListView.builder(
                  itemCount: list.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ChatUserCard(
                      user: list[index],
                    );
                    // return Text('${list[index]}');
                  });
            } else {
              return const Center(child: Text("No Connection Found!"));
            }
          }

          //   final list = [];
          //   if (snapshot.hasData) {
          //     final data = snapshot.data?.docs;
          //     for (var i in data!) {
          //       log('\n Data: ${jsonEncode(i.data())}');
          //       list.add(i.data()['name']);
          //     }
          //     // log('\n Data from firestor =${data}');
          //   }
          //   return ListView.builder(
          //       itemCount: list.length,
          //       physics: BouncingScrollPhysics(),
          //       itemBuilder: (context, index) {
          //         // return ChatUserCard();
          //         return Text('${list[index]}');
          //       });
          // },
          ),
    );
  }
}
