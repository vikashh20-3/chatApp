import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/apis.dart';
import 'auth/login.dart';
import 'home_screen.dart';

//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Color.fromARGB(255, 255, 255, 255)));

      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        //navigate to home screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        //navigate to login screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Login()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)

    return Scaffold(
      //body
      body: Stack(children: [
        //app logo
        Positioned(
            top: MediaQuery.of(context).size.height * .15,
            right: MediaQuery.of(context).size.width * .25,
            width: MediaQuery.of(context).size.width * .5,
            child: Image.asset('images/chat.png')),

        //google login button
        Positioned(
            bottom: MediaQuery.of(context).size.height * .15,
            width: MediaQuery.of(context).size.width,
            child: const Text('MADE IN INDIA WITH ❤️',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.black87, letterSpacing: .5))),
      ]),
    );
  }
}
