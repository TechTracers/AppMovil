import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lock_item/screens/Account/login_screen.dart';
import 'package:lock_item/screens/main_screen.dart';
import 'package:lock_item/screens/Account/sign_up_screen.dart';
import 'firebase_options.dart'; // Archivo generado automáticamente por FlutterFire CLI

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Firebase usando las opciones generadas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LockItem App',
      initialRoute: '/login', // Ruta inicial
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}
