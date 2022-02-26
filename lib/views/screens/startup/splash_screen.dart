
import 'package:biniyog/services/navigation_service.dart';
import 'package:biniyog/views/screens/auth/login_screen.dart';
import 'package:biniyog/views/styles/k_colors.dart';
import 'package:biniyog/views/styles/k_text_style.dart';
import 'package:flutter/material.dart';


import 'dart:async';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 2),
        () => Navigator.push(context,
            FadeRoute(page: LoginScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColor.primary,
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/b_logo.png",
                height: 58,
                width: 51.66,
              ),
              SizedBox(
                height:  10,
              ),
              Text(
                "Biniyog",
                style: KTextStyle.headline2,
              )
            ],
          ),
        ),
      ),
    );
  }
}
