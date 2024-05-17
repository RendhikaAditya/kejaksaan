import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kejaksaan/utils/sesionManager.dart';
import 'package:kejaksaan/view/PageLaporanJmsList.dart';
import 'package:kejaksaan/view/homePage.dart';

import '../model/modelLaporanJms.dart';
import '../utils/apiUrl.dart';

class LaporanJmsPage extends StatefulWidget {
  final Datum? data;
  const LaporanJmsPage(this.data, {Key? key}) : super(key: key);

  @override
  State<LaporanJmsPage> createState() => _LaporanJmsPageState();
}

class _LaporanJmsPageState extends State<LaporanJmsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controllerLaporan = TextEditingController();


  Future<void> _tambahData() async {
    if (_formKey.currentState!.validate()) {
      final String apiUrl = '${ApiUrl().baseUrl}jms.php';


      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      if(widget.data!=null){
        request.fields['id_jms'] = widget.data!.idJms;
      }
      // Menambahkan data teks
      request.fields['id_user'] = sessionManager.idUser.toString();
      request.fields['sekolah'] = _controllerLaporan.text;
      request.fields['status'] = "Pending";

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          // Jika berhasil, periksa respons JSON
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['sukses']) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => PageLaporanJmsList()),
                    (route) => false
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${jsonResponse['pesan']}')),
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
  }


  @override
  Widget build(BuildContext context) {
    _controllerLaporan= widget.data != null
        ? TextEditingController(text: widget.data!.sekolah.toString())
        : TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.data==null?'Buat Laporan JMS':'Edit Laporan JMS',
          style: TextStyle(
            color: Colors.white,
          ), // Ubah warna teks menjadi putih
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controllerLaporan,
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: "Laporan Singkat",
                  // Menengahkan teks secara horizontal
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sekolah tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    _tambahData();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[900],
                  ),
                  child: Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
