import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kejaksaan/utils/sesionManager.dart';
import 'package:kejaksaan/view/RegistProfil.dart';

import '../utils/apiUrl.dart';
import '../utils/pdfView.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFEFCEF),
      appBar: AppBar(
        title: Text('Profil Pengguna'),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset("images/icon.jpeg", width: 150,),
                SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileItem(
                      icon: Icons.person,
                      value: '${sessionManager.fullname}',
                    ),
                    ProfileItem(
                      icon: Icons.star,
                      value: '${sessionManager.level}',
                    ),
                    ProfileItem(
                      icon: Icons.home,
                      value: '${sessionManager.alamat}',
                    ),
                    ProfileItem(
                      icon: Icons.phone,
                      value: '${sessionManager.nohp}',
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PdfViewPage(
                                url: "${ApiUrl().baseUrl}${sessionManager.ktp}", title: "KTP ${sessionManager.fullname}",)),
                      );
                    },
                    child: Text('Lihat Ktp'),
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegistProfile())
                      );
                    },
                    child: Text('Update Profil'),
                  ),
                ),
              ],
            )

          ]
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String value;

  ProfileItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 10),
          Text(value),
        ],
      ),
    );
  }
}
