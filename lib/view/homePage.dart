import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kejaksaan/utils/sesionManager.dart';
import 'package:kejaksaan/view/PageLaporanJmsList.dart';
import 'package:kejaksaan/view/PageLaporanList.dart';
import 'package:http/http.dart' as http;
import 'package:kejaksaan/view/loginPage.dart';
import 'package:kejaksaan/view/profilPage.dart';

import '../utils/apiUrl.dart';
import '../widget/imageSlider.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _tambahRating(int rating) async {
      final String apiUrl = '${ApiUrl().baseUrl}rating.php';


      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Menambahkan data teks
      request.fields['id_user'] = "${sessionManager.idUser}";
      request.fields['rating'] = "$rating";

      print("${sessionManager.idUser}\n${rating}");

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          // Jika berhasil, periksa respons JSON
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['sukses']) {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Rating berhasil ditambahkan')),
            );

          } else {
            // Tampilkan pesan error dari server
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse['pesan'])),
            );
          }
        } else {
          // Tanggapan tidak berhasil, tampilkan kode status
          throw Exception(
              'Gagal menambahkan data sejarawan: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Gagal melakukan request: $e');
      }
   
  }

  void _showRatingDialog() {
    int rating = 0;

    showDialog<void>(
      context: context,
      barrierDismissible: false, // dialog tidak dapat ditutup dengan mengetuk di luar dialog
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Berikan Rating'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Beri rating untuk aplikasi ini:'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.star, color: rating >= 1 ? Colors.yellow : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 1;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.star, color: rating >= 2 ? Colors.yellow : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 2;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.star, color: rating >= 3 ? Colors.yellow : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 3;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.star, color: rating >= 4 ? Colors.yellow : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 4;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.star, color: rating >= 5 ? Colors.yellow : Colors.grey),
                        onPressed: () {
                          setState(() {
                            rating = 5;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // menutup dialog tanpa memberikan rating
                  },
                  child: Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _tambahRating(rating);
                  },
                  child: Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  final List<String> images = [
    'https://assets.promediateknologi.id/crop/0x0:0x0/750x500/webp/photo/2023/03/16/IMG_20230316_101522-795259457.jpg',
    'https://rekrutmen.kejaksaan.go.id/uploads/news/title_img/04ce8b3174d4ca440b56246b463b4cd9.png',
    'https://www.kejaksaan.go.id/uploads/layanan/212f2a5d9889f30e16707f58690c04c1.png',
  ];
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    print(sessionManager.ktp);

    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0,top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hallo,',
                      style: TextStyle(
                        color: Color(0xFF0E2A47),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_circle, // Ganti dengan ikon profil yang sesuai
                            size: 24,
                            color: Color(0xFF0E2A47),
                          ),
                          SizedBox(width: 10), // Jarak antara teks dan ikon

                          Text(
                            '${sessionManager.fullname}',
                            style: TextStyle(
                              color: Color(0xFF0E2A47),
                              fontSize: 18,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),

              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Container(
                        height: 200, // Adjust the height as needed
                        child: ImageSlider(),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PageLaporanList()),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'images/ic_laporan.png',
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(width: 10),
                          sessionManager.level=="Admin"
                          ? Text(
                            'Data Laporan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          :Text(
                            'Buat Laporan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Pengaduan Pegawai,\n'
                            'Pengaduan Tindak Pidana Korupsi,\n'
                            'Penyuluhan Hukum,\n'
                            'Pengawasan Aliran Dan Kepercayaan,\n'
                            'Posko Pilkada',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PageLaporanJmsList()),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'images/ic_jms.png',
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(width: 10),
                          sessionManager.level=="Admin"
                              ? Text(
                            'Data Laporan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              :Text(
                            'Buat Laporan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Jaksa Masuk Sekolah Atau JMS',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showRatingDialog,
                child: Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'images/ic_rating.png',
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Rating Aplikasi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await sessionManager.clearSession();
                  sessionManager.getSession();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20,bottom: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'images/ic_logout.png',
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
