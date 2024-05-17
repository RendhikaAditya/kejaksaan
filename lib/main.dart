import 'package:flutter/material.dart';
import 'package:kejaksaan/view/homePage.dart';
import 'package:kejaksaan/view/laporanPage.dart';
import 'package:kejaksaan/view/loginPage.dart';
import 'package:kejaksaan/view/splashScree.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
