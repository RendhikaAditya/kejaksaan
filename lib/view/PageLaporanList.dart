import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kejaksaan/utils/pdfView.dart';
import 'package:kejaksaan/utils/sesionManager.dart';
import 'package:kejaksaan/view/detailLaporanPage.dart';
import 'package:kejaksaan/view/laporanPage.dart';
import 'package:http/http.dart' as http;

import '../model/modelLaporan.dart';
import '../utils/apiUrl.dart';
import 'homePage.dart';

class PageLaporanList extends StatefulWidget {
  const PageLaporanList({super.key});

  @override
  State<PageLaporanList> createState() => _PageLaporanListState();
}

class _PageLaporanListState extends State<PageLaporanList> {
  String? _selectedOption;
  late Future<List<Datum>?> _futureLaporan;
  List<Datum>? _filterResult;

  @override
  void initState() {
    super.initState();
    _futureLaporan = getLaporan();
    sessionManager.getSession();
  }

  Future<void> refreshLaporan() async {
    setState(() {
      _futureLaporan = getLaporan();
    });
  }

  void _showOptionsDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Pilih Opsi'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Pengaduan Pegawai');
              },
              child: Text('Pengaduan Pegawai'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Pengaduan Tindak Pidana Korupsi');
              },
              child: Text('Pengaduan Tindak Pidana Korupsi'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Penyuluhan Hukum');
              },
              child: Text('Penyuluhan Hukum'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Pengawasan Aliran Dan Kepercayaan');
              },
              child: Text('Pengawasan Aliran Dan Kepercayaan'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Posko Pilkada');
              },
              child: Text('Posko Pilkada'),
            ),
          ],
        );
      },
    ).then((selectedValue) {
      if (selectedValue != null) {
        setState(() {
          _selectedOption = selectedValue;
          filterLaporan(selectedValue);
        });
      }
    });
  }

  Future<List<Datum>?> getLaporan() async {
    try {
      http.Response res = await http.get(Uri.parse(
          sessionManager.level == "Admin"
              ? '${ApiUrl().baseUrl}laporan.php'
              : '${ApiUrl().baseUrl}laporan.php?id=${sessionManager.idUser}'));

      print("Terjadi kesalahan: ${modelLaporanFromJson(res.body).pesan}");

      if (modelLaporanFromJson(res.body).sukses) {
        print("Data diperoleh :: ${modelLaporanFromJson(res.body).data}");
        return modelLaporanFromJson(res.body).data;
      } else {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${modelLaporanFromJson(res.body).pesan}")),
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

  Future<void> filterLaporan(String query) async {
    if (query.isEmpty) {
      setState(() {
        _selectedOption = null;
      });
      return;
    }
    List<Datum>? laporan = await getLaporan();
    if (laporan != null) {
      List<Datum> result = laporan
          .where((datum) =>
              datum.tipeLaporan!.toLowerCase() == (query.toLowerCase()))
          .toList();
      setState(() {
        _filterResult = result;
      });
    }
  }

  Future<void> _editData(Datum dataItem, String status) async {
    final String apiUrl = '${ApiUrl().baseUrl}laporan.php';
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['id_user'] = dataItem.idUser;
    request.fields['id_laporan'] = dataItem.idLaporan;
    request.fields['laporan_text'] = dataItem.laporanText;
    request.fields['laporan_pdf'] = "";
    request.fields['status'] = status;
    request.fields['tipe_laporan'] = dataItem.tipeLaporan;

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
    final String apiUrl = '${ApiUrl().baseUrl}laporan.php';

    try {
      var response = await http.get(Uri.parse("$apiUrl?id_laporan=$id"));

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan'),
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
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                textAlign: TextAlign.start,
                'Pilih Tipe Laporan:',
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showOptionsDialog,
                  child: Text('Pilih Opsi'),
                ),
              ),
              SizedBox(height: 20),
              _selectedOption != null
                  ? Text('Opsi dipilih: $_selectedOption')
                  : Text('Belum ada opsi dipilih'),
            ],
          ),
        ),
        Expanded(
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
                  final data = _filterResult ?? snapshot.data;
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
                              sessionManager.level != "Admin"
                                  ? Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PdfViewPage(
                                                url:
                                                    "${ApiUrl().baseUrl}${dataItem.laporanPdf}",
                                                title: dataItem.laporanPdf,
                                              )),
                                    )
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DetailLaporanPage(
                                                laporan: dataItem,
                                              )),
                                    );
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'images/ic_laporan.png',
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
                                                    '${dataItem.tipeLaporan}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    '${dataItem.laporanText}',
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
                                        dataItem.status.toLowerCase() ==
                                                "pending"
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
                                                                  horizontal:
                                                                      40),
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
                                                                  horizontal:
                                                                      50),
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
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Status: ',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      dataItem.status ==
                                                              "Pending"
                                                          ? ElevatedButton(
                                                              onPressed: () {},
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            50),
                                                                backgroundColor:
                                                                    Colors
                                                                        .grey, // Warna latar belakang tombol
                                                              ),
                                                              child: Text(
                                                                  'Pending',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black)),
                                                            )
                                                          : dataItem.status ==
                                                                  "Approved"
                                                              ? ElevatedButton(
                                                                  onPressed:
                                                                      () {},
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            50),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .green, // Warna latar belakang tombol
                                                                  ),
                                                                  child: Text(
                                                                      'Approved',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                )
                                                              : ElevatedButton(
                                                                  onPressed:
                                                                      () {},
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            50),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red, // Warna latar belakang tombol
                                                                  ),
                                                                  child: Text(
                                                                      'Rejected',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.white)),
                                                                )
                                                    ],
                                                  )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Status: ',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  dataItem.status == "Pending"
                                                      ? ElevatedButton(
                                                          onPressed: () {},
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        50),
                                                            backgroundColor: Colors
                                                                .grey, // Warna latar belakang tombol
                                                          ),
                                                          child: Text('Pending',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        )
                                                      : dataItem.status ==
                                                              "Approved"
                                                          ? ElevatedButton(
                                                              onPressed: () {},
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            50),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green, // Warna latar belakang tombol
                                                              ),
                                                              child: Text(
                                                                  'Approved',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                            )
                                                          : ElevatedButton(
                                                              onPressed: () {},
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            50),
                                                                backgroundColor:
                                                                    Colors
                                                                        .red, // Warna latar belakang tombol
                                                              ),
                                                              child: Text(
                                                                  'Rejected',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)),
                                                            )
                                                ],
                                              )
                                      ]),
                                  sessionManager.level == "Admin"
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PdfViewPage(
                                                        url:
                                                            "${ApiUrl().baseUrl}${dataItem.laporanPdf}",
                                                        title:
                                                            dataItem.laporanPdf,
                                                      )),
                                            );
                                          },
                                          child: Icon(
                                              Icons.picture_as_pdf_outlined))
                                      : dataItem.status.toLowerCase() ==
                                              "pending"
                                          ? GestureDetector(
                                              onTap: () {
                                                _hapusData(context,
                                                    dataItem.idLaporan);
                                              },
                                              child: Icon(Icons.delete_outline))
                                          : GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PdfViewPage(
                                                            url:
                                                                "${ApiUrl().baseUrl}${dataItem.laporanPdf}",
                                                            title: dataItem
                                                                .laporanPdf,
                                                          )),
                                                );
                                              },
                                              child: Icon(Icons
                                                  .remove_red_eye_outlined)),
                                ],
                              ),
                            ),
                          );
                        });
                  }
                }
              }),
        ),
      ]),
      floatingActionButton: sessionManager.level != "Admin"
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LaporanPage()),
                );
              },
              tooltip: 'Add Report',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
