import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils/apiUrl.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controllerLaporan = TextEditingController();


  File? _selectedFile;
  String _base64String = '';

  String? _selectedOption;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      _selectedFile = File(result.files.single.path!);
      _convertToBase64();
      print(_base64String);
      setState(() {});
    }
  }

  Future<void> _convertToBase64() async {
    if (_selectedFile != null) {
      List<int> fileBytes = await _selectedFile!.readAsBytes();
      _base64String = base64Encode(fileBytes);
      setState(() {});
    } else {
      // Handle case when no file is selected
    }
  }

  Future<void> _tambahDataSejarawan() async {
    if (_formKey.currentState!.validate()) {
      final String apiUrl = '${ApiUrl().baseUrl}laporan.php';


      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Menambahkan data teks
      request.fields['id_user'] = "1";
      request.fields['laporan_text'] = _controllerLaporan as String;
      request.fields['laporan_pdf'] = _base64String;
      request.fields['status'] = "Dilaporkan";
      request.fields['tipe_laporan'] = _selectedOption as String;

      try {
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          // Jika berhasil, periksa respons JSON
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['sukses']) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data berhasil ditambahkan')),
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
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buat Laporan',
          style: TextStyle(
            color: Colors.white,
          ), // Ubah warna teks menjadi putih
        ),
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pilih Tipe Laporan:',
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
              SizedBox(height: 12),
              TextFormField(
                controller: _controllerLaporan,
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: "Laporan Singkat",
                  // Menengahkan teks secara horizontal
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _pickPDF,
                      child: Text('Pilih PDF'),
                    ),
                  ),
                  SizedBox(height: 20),
                  _selectedFile != null
                      ? Text('File dipilih: ${_selectedFile!.path}')
                      : Text('Belum ada file dipilih'),
                  SizedBox(height: 20),
                ],
              ),
              SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){},
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
