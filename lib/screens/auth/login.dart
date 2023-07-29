import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

@override
// GoogleAuthProvider googleProvider = GoogleAuthProvider();

// googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
// googleProvider.setCustomParameters({
//   'login_hint': 'user@example.com'
// });

_googleBtnClick() {
  _signInWithGoogle().then((user) {
    log('\nUser : ${user.user}');
    // Navigator.pushReplacement(,
    //     MaterialPageRoute(builder: (context) => const HomeScreen()));
  });
}

//GOOGLE SIGN IN CODE FOR WEB

//GOOGLE SIGN IN CODE FOR ANDROID AND IOS
Future<UserCredential> _signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Welcome to We Chat",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.lightBlue),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(children: [
        Positioned(
            width: MediaQuery.of(context).size.width * .5,
            height: MediaQuery.of(context).size.height * .30,
            left: MediaQuery.of(context).size.width * .25,
            child: Image.asset('images/chat.png')),
        Positioned(
          width: MediaQuery.of(context).size.width - 70,
          bottom: MediaQuery.of(context).size.height * .12,
          left: MediaQuery.of(context).size.width * .15,
          height: MediaQuery.of(context).size.width * .08,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue, elevation: 9),
            onPressed: () {
              _googleBtnClick();
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: ((context) => const HomeScreen())));
            },
            icon: Image.asset(
              'images/google.png',
              height: MediaQuery.of(context).size.height * .05,
            ),
            label: RichText(
              text: const TextSpan(
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  children: [
                    TextSpan(text: 'Sign In With '),
                    TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ]),
            ),
            // label: Text(
            //   "Sign in With Google",
            // )
          ),
          // child: Image.asset(
          //     '/home/vikash/Desktop/Flutter/chatapp/images/chat.png'))
        ),
      ]),
    );
  }
}
