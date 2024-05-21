import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kejaksaan/utils/sesionManager.dart';

import '../model/modelLaporan.dart';
import '../model/modelUser.dart';
import '../utils/apiUrl.dart';
import '../utils/pdfView.dart';
import 'PageLaporanList.dart';

class DetailLaporanPage extends StatefulWidget {
  final Datum laporan;
  const DetailLaporanPage({Key? key, required this.laporan}) : super(key: key);

  @override
  State<DetailLaporanPage> createState() => _DetailLaporanPageState();
}

class _DetailLaporanPageState extends State<DetailLaporanPage> {
  String? nama;
  String noHp = "";
  String ktp = "";

  Future<ModelUser?> getUser(String idUser) async {
    try {
      http.Response res = await http.get(Uri.parse('${ApiUrl().baseUrl}auth.php?id_user=${idUser}'));

      if (res.statusCode == 200) {
        // Response OK, parse JSON
        final parsedJson = json.decode(res.body);
        print("HTTP: ${parsedJson}");

        // Convert parsed JSON to ModelUser
        ModelUser userModel = ModelUser.fromJson(parsedJson);

        // Update state with retrieved data
        setState(() {
          nama = userModel.data!.nama;
          noHp = userModel.data!.noTelpon;
          ktp = userModel.data!.ktp;
        });

        // Access the name property and print it
        print("Nama: $nama");

        return userModel;
      } else {
        // Handle HTTP error response
        print("HTTP Error: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      // Handle other errors
      print("Terjadi kesalahan: $e");
      return null;
    }
  }
  Future<void> _editData(Datum dataItem, String status) async {
    final String apiUrl = '${ApiUrl().baseUrl}laporan.php';
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.fields['id_user'] = sessionManager.idUser.toString();
    request.fields['id_laporan'] = dataItem.idLaporan;
    request.fields['laporan_text'] = dataItem.laporanText;
    request.fields['laporan_pdf'] = "";
    request.fields['status'] =status;
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
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PageLaporanList()),
                  (route) => false
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
            'Gagal memperbarui data : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal melakukan request: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getUser(widget.laporan.idUser);
  }

  @override
  Widget build(BuildContext context) {
    final Datum laporan = widget.laporan;
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Laporan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, // Set width to match parent
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text("Data Pelapor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      ),
                      SizedBox(height: 16,),
                      Text(
                        'Nama : ${nama ?? ""}', // use ?? to handle null value
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nomor Hp : $noHp',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'KTP: ',
                            style: TextStyle(fontSize: 18),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PdfViewPage(
                                        url:
                                        "${ApiUrl().baseUrl}${ktp}", title: "Ktp $nama",)),
                              );
                            },
                            child: Text('Lihat KTP'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Laporan: ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Tipe Laporan : ${laporan.tipeLaporan}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Isi Laporan : ${laporan.laporanText}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PdfViewPage(url:"${ApiUrl().baseUrl}${laporan.laporanPdf}", title: laporan.laporanPdf,)),
                );
              },
              child: Text('Lihat File Laporan'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: Colors.white,
        child: laporan.status=="Pending"
            ?Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _editData(laporan, "Rejected");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Reject', style: TextStyle(color: Colors.white),),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _editData(laporan, "Approved");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Approve', style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        )
            :null,
      ),
    );
  }
}
