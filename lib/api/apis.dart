import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

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
  static get user => auth.currentUser;
  //for checking user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

// add chat user
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessageToken();
        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for creating  a new  user

  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      name: auth.currentUser!.displayName.toString(),
      id: auth.currentUser!.uid,
      email: auth.currentUser!.email.toString(),
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
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\n useIds: $userIds');
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: user!.uid)
        .snapshots();
  }

  // for getting selected users from firebase
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsers() {
    return APIs.firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for add your user after sending first message
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for update user data in firebase
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user!.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // FOR ACCESING FIREBASE MESSAGING(PUSH NOTIFICATION)

  // update profile picture of user
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //For getting firebase message token

  static Future<void> getFirebaseMessageToken() async {
    await fMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('push Token : ${t}');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": 'chats',
        }
      };
      var res = await post(Uri.parse('https://fmc.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAA2EqVbmw:APA91bGvipjB4BkbUvYQpuSCfWGDATSOuSFGlM7wIfeuOubTf4f7JyDWWF0FPnx8lCcRToHxwtS7PE3pBdhlMGi8UOBl3QEk86qQAfnXFF83bWHYIj31I-auFNnliiuhKVwBRfNR_Dt7'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\n SendPushNotification: ${e}');
    }
  }

  static Future<void> updateUserPic(File file) async {
    final ext = file.path.split('.').last;
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
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as doc id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    log('sendMessage - chatUser.uid: ${chatUser.id}');
    //message to send
    final Message message = Message(
        fromId: user.uid,
        msg: msg,
        read: '',
        sent: time,
        toId: chatUser.id,
        type: type);
    final ref = firestore.collection(
        'chats/${getConversationId(chatUser.id.toString())}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'Image'));
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
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // upload image to firebase

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    log('\nExtension ${ext}');
    final ref = storage.ref().child(
        'Images / ${getConversationId(chatUser.id.toString())}/${DateTime.now().millisecondsSinceEpoch}/${user.uid}');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/${ext}'))
        .then((p0) {
      log('File Upload : ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  //for delete a sended message
  // static Future<void> deleteMessage(Message message) async {
  //   await firestore
  //       .collection(
  //           'chats/${getConversationId(message.toId.toString())}/messages/')
  //       .doc(message.sent)
  //       .delete();

  //   if (message.type == Type.image) {
  //     await storage.refFromURL(message.msg.toString()).delete();
  //   }
  // }

  static Future<void> deleteMessage(Message message) {
    return firestore
        .collection(
            'chats/${getConversationId(message.toId.toString())}/messages/')
        .doc(message.sent)
        .delete();
  }

  //for update a sended message
  //update message
  static Future<void> updateMessage(
      Message message, String updateMessage) async {
    await firestore
        .collection(
            'chats/${getConversationId(message.toId.toString())}/messages/')
        .doc(message.sent)
        .update({'msg': updateMessage});
  }
}
