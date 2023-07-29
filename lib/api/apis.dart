import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  // For FireStore Database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
}
