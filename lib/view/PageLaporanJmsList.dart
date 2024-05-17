import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kejaksaan/view/laporanJMSPage.dart';
import 'package:kejaksaan/view/laporanPage.dart';

import '../model/modelLaporanJms.dart';
import 'package:http/http.dart' as http;

import '../utils/apiUrl.dart';
import '../utils/pdfView.dart';
import '../utils/sesionManager.dart';
import 'homePage.dart';

class PageLaporanJmsList extends StatefulWidget {
  const PageLaporanJmsList({super.key});

  @override
  State<PageLaporanJmsList> createState() => _PageLaporanJmsListState();
}

class _PageLaporanJmsListState extends State<PageLaporanJmsList> {
  late Future<List<Datum>?> _futureLaporan;

  Future<List<Datum>?> getLaporan() async {
    try {
      http.Response res = await http.get(Uri.parse(
          sessionManager.level=="admin"
              ?'${ApiUrl().baseUrl}jms.php'
              :'${ApiUrl().baseUrl}jms.php?id=${sessionManager.idUser}'
      ));

      if(modelLaporanJmsFromJson(res.body).sukses){
        print("Data diperoleh :: ${modelLaporanJmsFromJson(res.body).data}");
        return modelLaporanJmsFromJson(res.body).data;
      }else{
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${modelLaporanJmsFromJson(res.body).pesan}")),
          );
        });
      }

    } catch (e) {
      print("Terjadi kesalahan: $e");
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      });
      return null; // Kembalikan null jika terjadi kesalahan
    }
  }

  Future<void> refreshLaporan() async {
    setState(() {
      _futureLaporan = getLaporan();
    });
  }

  Future<void> _editData(Datum dataItem, String status) async {
    final String apiUrl = '${ApiUrl().baseUrl}jms.php';
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['id_user'] = '1';
    request.fields['id_jms'] = dataItem.idJms;
    request.fields['sekolah'] = dataItem.sekolah;
    request.fields['status'] = status;

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Jika berhasil, periksa respons JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['sukses']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data berhasil diperbarui')),
          );
          refreshLaporan();
        } else {
          // Tampilkan pesan error dari server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['pesan'])),
          );
        }
      } else {
        // Tanggapan tidak berhasil, tampilkan kode status
        throw Exception('Gagal memperbarui data : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal melakukan request: $e');
    }
  }

  void _hapusData(BuildContext context, String id) async {
    final String apiUrl = '${ApiUrl().baseUrl}jms.php';

    try {
      var response = await http.get(Uri.parse("$apiUrl?id_jms=$id"));

      if (response.statusCode == 200) {
        // Jika berhasil, periksa respons JSON
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['sukses']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data  berhasil dihapus')),
          );
          refreshLaporan();
        } else {
          // Tampilkan pesan error dari server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['pesan'])),
          );
        }
      } else {
        // Tanggapan tidak berhasil, tampilkan kode status
        throw Exception('Gagal menghapus data : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal melakukan request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureLaporan = getLaporan();
    sessionManager.getSession();
    refreshLaporan();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Setiap kali widget menjadi aktif kembali, panggil refreshLaporan
    refreshLaporan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan JMS'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Expanded(
        child: FutureBuilder(
            future: _futureLaporan,
            builder:
                (BuildContext context, AsyncSnapshot<List<Datum>?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                final data = snapshot.data;
                if (data == null || data.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada data ditemukan."),
                  );
                } else {
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        Datum? dataItem = data[index];
                        return GestureDetector(
                          onTap: () {
                            if (sessionManager.level != "Admin") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LaporanJmsPage(dataItem),
                                ),
                              );
                            } else {
                              // Tidak ada aksi yang diambil jika level bukan "Admin"
                            }
                          },
                          child: Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 20, top: 20),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'images/ic_jms.png',
                                            width: 50,
                                            height: 50,
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width:
                                                    200, // Atur lebar maksimum teks di sini
                                                child: Text(
                                                  'Jaksa Masuk Sekolah',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines:
                                                      2, // Atur jumlah maksimum baris
                                                  overflow: TextOverflow
                                                      .ellipsis, // Tampilkan titik-titik jika teks terlalu panjang
                                                ),
                                              ),
                                              Container(
                                                width:
                                                    200, // Atur lebar maksimum teks di sini
                                                child: Text(
                                                  '${dataItem.sekolah}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  maxLines:
                                                      5, // Atur jumlah maksimum baris
                                                  overflow: TextOverflow
                                                      .ellipsis, // Tampilkan titik-titik jika teks terlalu panjang
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      dataItem.status.toLowerCase() == "pending"
                                          ? sessionManager.level == "Admin"
                                              ? Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _editData(dataItem,
                                                            "Rejected");
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 40),
                                                        backgroundColor: Colors
                                                            .red, // Warna latar belakang tombol
                                                      ),
                                                      child: Text(
                                                        'Reject',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _editData(dataItem,
                                                            "Approved");
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 50),
                                                        backgroundColor: Colors
                                                            .green, // Warna latar belakang tombol
                                                      ),
                                                      child: Text('Approve',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  'Status: ${dataItem.status}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                )
                                          : Text(
                                              'Status: ${dataItem.status}',
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                    ]),
                                sessionManager.level == "Admin"
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Icon(Icons.school_outlined))
                                    : dataItem.status.toLowerCase() == "pending"
                                        ? GestureDetector(
                                            onTap: () {
                                              _hapusData(
                                                  context, dataItem.idJms);
                                            },
                                            child: Icon(Icons.delete_outline))
                                        : GestureDetector(
                                            onTap: () {},
                                            child: Icon(Icons.school_outlined)),
                              ],
                            ),
                          ),
                        );
                      });
                }
              }
            }),
      ),
      floatingActionButton: sessionManager.level != "Admin"
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LaporanJmsPage(null)),
          );
        },
        tooltip: 'Add Report',
        child: const Icon(Icons.add),
      )
          : null, // Jika level "Admin", tidak ada FloatingActionButton yang ditampilkan
    );
  }
}
