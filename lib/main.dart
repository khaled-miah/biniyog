import 'package:biniyog/views/screens/auth/login_screen.dart';
import 'package:biniyog/views/screens/auth/sign_up_screen.dart';
import 'package:biniyog/views/screens/splash_screen.dart';
import 'package:biniyog/views/screens/startup/splash_screen.dart';
import 'package:flutter/material.dart';
import 'views/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.lightGreenAccent),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
