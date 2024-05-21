import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kejaksaan/utils/sesionManager.dart';
import 'package:kejaksaan/view/loginPage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      sessionManager.getSession();
      print("splash :: ${sessionManager.idUser}");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginPage(),
        ),
      );
    });
    return Scaffold(
      backgroundColor: Color(0xffFEFCEF),
      body: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/icon.jpeg',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Pusat Informasi\nKejaksaan Tinggi Sumbar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),

      ),
    );
  }
}
