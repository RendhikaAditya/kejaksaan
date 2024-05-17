import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kejaksaan/view/homePage.dart';
import 'package:kejaksaan/widget/custom_text_field.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../model/modelBase.dart';
import '../utils/apiUrl.dart';
import '../utils/sesionManager.dart';
import '../widget/password_text_field.dart';

class RegistProfile extends StatefulWidget {
  const RegistProfile({super.key});

  @override
  State<RegistProfile> createState() => _RegistProfileState();
}

class _RegistProfileState extends State<RegistProfile> {
  TextEditingController _txtNama = TextEditingController();
  TextEditingController _txtAlamat = TextEditingController();
  TextEditingController _txtNoTelpon = TextEditingController();
  TextEditingController _txtEmail = TextEditingController();
  TextEditingController _txtPassword = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var logger = Logger();

  File? _selectedFile;
  String _base64String = '';

  @override
  void initState() {
    super.initState();
    sessionManager.getSession().then((value) {
      setState(() {
        _txtNama = sessionManager.fullname != null ? TextEditingController(text: sessionManager.fullname) : TextEditingController();
        _txtAlamat = sessionManager.alamat != null ? TextEditingController(text: sessionManager.alamat) : TextEditingController();
        _txtNoTelpon = sessionManager.nohp != null ? TextEditingController(text: sessionManager.nohp) : TextEditingController();
        _txtEmail = sessionManager.email != null ? TextEditingController(text: sessionManager.email) : TextEditingController();
      });
    });
  }

  Future<ModelBase?> pushData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        http.Response res;

        // Prepare request body
        Map<String, String> requestBody = {
          "nama": _txtNama.text,
          "email": _txtEmail.text,
          "no_telpon": _txtNoTelpon.text,
          "ktp": _base64String != '' ? _base64String : '',
          "alamat": _txtAlamat.text,
          "password": _txtPassword.text,
          "level": sessionManager.level != null ? sessionManager.level! : 'Customer'
        };

        // Determine URL based on sessionManager.idUser
        Uri url = sessionManager.idUser != null
            ? Uri.parse('${ApiUrl().baseUrl}auth.php?id_user=${sessionManager.idUser}')
            : Uri.parse('${ApiUrl().baseUrl}auth.php');

        // Perform POST request
        res = await http.post(url, body: requestBody);

        print("ISI RES ::: \n\n ${res.body} \n\n");

        // Decode response body
        ModelBase data = modelBaseFromJson(res.body);
        print(sessionManager.idUser);

        try {
          if (sessionManager.idUser != null) {
            sessionManager.saveSession(
              data.sukses!,
              sessionManager.idUser as String,
              _txtEmail.text,
              _txtNama.text,
              _txtAlamat.text,
              _txtNoTelpon.text,
              _base64String != '' ? _base64String : sessionManager.ktp.toString(),
              sessionManager.level.toString(),
            );
            sessionManager.getSession();
          }
        } catch (e) {
          print("Error Session save : $e");
        }

        if (data.sukses) {
          // Show appropriate Snackbar message based on response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data.sukses! ? "Sukses : ${data.pesan}" : "Gagal : ${data.pesan}")),
          );
          setState(() {
            isLoading = false;
            if(sessionManager.idUser==null){
              Navigator.pop(context);
            }else{
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false
              );
            }
          });
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error : ${e.toString()}")),
        );
        print("nama : ${_txtNama.text}\nalamat:${_txtAlamat.text}\nnohp:${_txtNoTelpon.text}\nemail:${_txtEmail.text}\npass:${_txtPassword.text}\nlevel:${sessionManager.level != null ? sessionManager.level! : 'Customer'}\nbase:${_base64String != '' ? _base64String : ''}");
      }
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      _selectedFile = File(result.files.single.path!);
      await _convertToBase64();
      print(_base64String);
    }
  }

  Future<void> _convertToBase64() async {
    if (_selectedFile != null) {
      List<int> fileBytes = await _selectedFile!.readAsBytes();
      setState(() {
        _base64String = base64Encode(fileBytes);
      });
    } else {
      // Handle case when no file is selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F9FF),
      appBar: AppBar(
        title: Text(
          sessionManager.value != null ? 'Edit Profil' : 'Registrasi Data',
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16,),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    hintText: "Nama Lengkap",
                    controller: _txtNama,
                    icon: Icons.person,
                  )
              ),
              SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    hintText: "Alamat",
                    controller: _txtAlamat,
                    icon: Icons.location_on,
                  )
              ),
              SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    hintText: "Nomor Hp",
                    controller: _txtNoTelpon,
                    icon: Icons.phone,
                  )
              ),
              SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CustomTextField(
                    hintText: "Email",
                    controller: _txtEmail,
                    icon: Icons.alternate_email_outlined,
                  )
              ),
              SizedBox(height: 20),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: PasswordTextField(
                    hintText: "Password",
                    controller: _txtPassword,
                  )
              ),
              SizedBox(height: 20,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Upload Ktp'),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _pickPDF,
                        child: Text('Pilih PDF'),
                      ),
                    ),
                    _selectedFile != null
                        ? Text('File dipilih: ${_selectedFile!.path}')
                        : sessionManager.ktp == null ? Text('Belum ada file dipilih') : Text('File Ktp : ${sessionManager.ktp}'),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : MaterialButton(
                  minWidth: 150,
                  height: 45,
                  onPressed: () {
                    pushData();
                  },
                  color: Colors.blue[900],
                  child: Text(sessionManager.idUser != null ? 'Edit' : 'Register', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
