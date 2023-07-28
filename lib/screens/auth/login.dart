import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
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
            child: Image.asset(
                '/home/vikash/Desktop/Flutter/chatapp/images/chat.png')),
        Positioned(
          width: MediaQuery.of(context).size.width * .75,
          bottom: MediaQuery.of(context).size.height * .12,
          left: MediaQuery.of(context).size.width * .15,
          height: MediaQuery.of(context).size.width * .08,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue, elevation: 9),
            onPressed: () {},
            icon: Image.asset(
              '/home/vikash/Desktop/Flutter/chatapp/assets/google.png',
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
