import 'package:flutter/material.dart';
import 'package:lock_item/screens/home/home_screen.dart';
import 'package:lock_item/screens/Account/login_screen.dart';
import 'package:lock_item/screens/main_screen.dart';
import 'package:lock_item/screens/Account/sign_up_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LockItem App',
      home: MainScreen(), // Cambia la ruta inicial a MainScreen
    );
  }
}

