import 'dart:developer';
import 'dart:io';

import 'package:chatapp/models/chat_user.dart';
import 'package:chatapp/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  // For FireStore Database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  // For Firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;
  // for storing self user information

  static late ChatUser me;
  //to return current user
  static get user => auth.currentUser!;
  //for checking user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for creating  a new  user

  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      name: auth.currentUser!.displayName,
      id: auth.currentUser!.uid,
      email: auth.currentUser!.email,
      about: 'Hey there I am using We Chat',
      image: auth.currentUser!.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: "",
    );
    return await firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .set(chatUser.toJson());
  }

  // for getting all users from firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for update user data in firebase
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user!.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // update profile picture of user

  static Future<void> updateUserPic(File file) async {
    final ext = file.path?.split('.').last;
    log('\nExtension ${ext}');
    final ref = storage.ref().child('profile_pictures/ ${user.uid}');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/${ext}'))
        .then((p0) {
      log('File Upload : ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update(
        {'image': me.image}).then((value) => log('profile pic updated'));
  }

  /// CHAT SCREEN RELATED API'S

  // for getting all MESSAGES from firebase
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages() {
  //   return APIs.firestore
  //       .collection('messages')
  //       // .where('id', isNotEqualTo: user.uid)
  //       .snapshots();
  // }

  //// USEFUL FOR GETTING COVERSATION ID
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      // ? '${user.uid}_$id'
      // : '${id}_${user.uid}';
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  ////FOR GETTING ALL MESSAGES FROM A SPECIFIC CONVERSATION FROM FIRESTORE DATABASE
  ///
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return APIs.firestore
        .collection('chats/${getConversationId(user.id.toString())}/messages/')
        .orderBy('sent', descending: false)
        .snapshots();
    // .collection('chats/${getConversationId(user.id.toString())}/messages/')
    // // .where('id', isNotEqualTo: user.uid)
    // .snapshots();
  }

  /// for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    //message sending time (also used as doc id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    //message to send
    final Message message = Message(
        fromId: user.uid,
        msg: msg,
        read: '',
        sent: time,
        toId: chatUser.uid,
        type: Type.text);
    final ref = firestore.collection(
        'chats/${getConversationId(chatUser.id.toString())}/messages/');
    await ref.doc(time).set(message.toJson());
  }

// update read status of messages
  static Future<void> updateMessageStatus(Message message) async {
    firestore
        .collection(
            'chats/${getConversationId(message.fromId.toString())}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only lase msg of specific chat

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return APIs.firestore
        .collection('chats/${getConversationId(user.id.toString())}/messages/')
        .limit(1)
        .snapshots();
  }
}
