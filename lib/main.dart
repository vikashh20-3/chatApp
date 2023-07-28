import 'package:flutter/material.dart';

import 'screens/auth/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'We Chat ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(color: Colors.black),
                // backgroundColor: Colors.white,
                backgroundColor: Colors.transparent)),
        home: const Login());
  }
}
