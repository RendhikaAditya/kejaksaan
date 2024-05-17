import 'package:flutter/material.dart';
import 'package:kejaksaan/utils/sesionManager.dart';
import 'package:kejaksaan/view/RegistProfil.dart';
import 'package:kejaksaan/view/homePage.dart';
import 'package:http/http.dart' as http;

import '../model/modelUser.dart';
import '../utils/apiUrl.dart';
import '../widget/custom_button.dart';
import '../widget/custom_text_field.dart';
import '../widget/password_text_field.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onLoggedIn;
  const LoginPage({super.key, this.onLoggedIn});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum FormMode { LOGIN, SIGNUP }

class _LoginPageState extends State<LoginPage> {
  TextEditingController txtEmail = TextEditingController();

  TextEditingController txtPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String? _email, password, errorMessage;

  ///deklarasi form untuk login
  FormMode formMode = FormMode.LOGIN;
  bool? isIos;
  bool? isLoading;

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // void _validateAndSubmit() async {
  //   setState(() {
  //     errorMessage = "";
  //     isLoading = true;
  //   });
  //   if (_validateAndSave()) {
  //     String userId = "";
  //     try {
  //       if (formMode == FormMode.LOGIN) {
  //         userId = await widget.auth!.signIn(_email ?? "", password ?? "");
  //
  //         setState(() {
  //           Navigator.pushAndRemoveUntil(
  //               context,
  //               MaterialPageRoute(builder: (_) => HomePage()),
  //               (route) => false);
  //         });
  //         print("user sign id : $userId");
  //       } else {
  //         userId = await widget.auth!.signUp(_email ?? "", password ?? "");
  //         setState(() {});
  //         widget.auth!.sendEmailVerification();
  //         _showDialogVerification();
  //         print("sign up id : $userId");
  //       }
  //       setState(() {
  //         isLoading = false;
  //       });
  //       if (userId.isNotEmpty && userId != null && formMode == FormMode.LOGIN) {
  //         widget.onLoggedIn;
  //         setState(() {});
  //       }
  //     } catch (e) {
  //       print("Error : $e");
  //       setState(() {
  //         isLoading = false;
  //         // if (isIos) {
  //         //   errorMessage = e.details;
  //         // } else {
  //         //   errorMessage = e.message;
  //         // }
  //       });
  //     }
  //   }
  // }

  void changeFormKeSingUp() {
    _formKey.currentState!.reset();
    errorMessage = "";
    setState(() {
      formMode = FormMode.SIGNUP;
    });
  }

  void changeFormKeLogin() {
    _formKey.currentState!.reset();
    errorMessage = "";
    setState(() {
      formMode = FormMode.LOGIN;
    });
  }

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    errorMessage = "";
    isLoading = false;

    print(sessionManager.value);
    if (sessionManager.value == true) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false //nanti ubah ke page class yang sebenarnya
          );
    }
  }

  void _showDialogVerification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Your Account'),
          content:
              const Text('Link to verify account has been sent to your email'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  changeFormKeLogin();
                  Navigator.of(context).pop();
                },
                child: const Text('Dismiss'))
          ],
        );
      },
    );
  }

  Future<ModelUser?> loginUser() async {
    try {
      setState(() {
        isLoading = true;
      });

      http.Response res = await http.post(
        Uri.parse('${ApiUrl().baseUrl}auth.php'),
        body: {
          "email": txtEmail.text,
          "password": txtPassword.text,
          "action": "login",
        },
      );

      ModelUser data = modelUserFromJson(res.body);
      print(data);

      if (data.sukses) {
        sessionManager.saveSession(
          data.sukses,
          data.data!.idUser,
          data.data!.email,
          data.data!.nama,
          data.data!.alamat,
          data.data!.noTelpon,
          data.data!.ktp,
          data.data!.level,
        );
        sessionManager.getSession();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${data.pesan}')),
        );



        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
          );
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${data.pesan}')),
        );

        setState(() {
          isLoading = false;
        });
      }

      return data;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print("email : ${txtEmail.text}\npassword:${txtPassword.text}\n${e.toString()}");

      setState(() {
        isLoading = false;
      });
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F9FF),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let’s Sign In.!",
                      style: TextStyle(
                        fontFamily: 'Jost',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Login to Your Account",
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              CustomTextField(
                hintText: "Email",
                controller: txtEmail,
                icon: Icons.mail_outline,
              ),
              SizedBox(height: 20),
              PasswordTextField(
                hintText: "Password",
                controller: txtPassword,
              ),
              SizedBox(height: 20),
              CustomButton(
                text: "Sign In",
                onPressed: () {
                  loginUser();
                  //
                  // print("${sessionManager.level} ada");
                  // sessionManager.level != null
                  //     ? Navigator.pushAndRemoveUntil(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => HomePage()),
                  //         (route) =>
                  //             false //nanti ubah ke page class yang sebenarnya
                  //         )
                  //     : sessionManager.saveSession(
                  //         true,
                  //         "1",
                  //         "email",
                  //         "Admin",
                  //         "alamat",
                  //         "nohp",
                  //         "pdf/ktp.pdf",
                  //         "Admin");
                  // sessionManager.getSession();
                  // print("${sessionManager.value} simpan");
                },
              ),
              SizedBox(height: 20),

              // "Don’t have an Account? SIGN UP" menjadi tengah
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an Account? ",
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF545454),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegistProfile()),
                        );
                      },
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
