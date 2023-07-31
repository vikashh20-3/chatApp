import 'package:chatapp/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  // For FireStore Database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
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
}
