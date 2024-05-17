import 'package:shared_preferences/shared_preferences.dart';

class SessionManager{
  bool? value;
  String? idUser;
  String? email;
  String? fullname;
  String? alamat;
  String? nohp;
  String? ktp;
  String? level;

  //simpan sesi
  Future<void> saveSession(bool val, String id, String email, String fullName, String alamat, String nohp, String ktp, String level) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("sukses", val);
    pref.setString("id_user", id);
    pref.setString("email", email);
    pref.setString("nama_user", fullName);
    pref.setString("alamat_user", alamat);
    pref.setString("nohp_user", nohp);
    pref.setString("ktp", ktp);
    pref.setString("level", level);
  }

  Future getSession() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    value = pref.getBool("sukses");
    idUser = pref.getString("id_user");
    email = pref.getString("email");
    fullname = pref.getString("nama_user");
    alamat =  pref.getString("alamat_user");
    nohp = pref.getString("nohp_user");
    ktp = pref.getString("ktp");
    level = pref.getString("level");
  }
  //remove --> logout
  Future clearSession() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

}

//instance class biar d panggil
SessionManager sessionManager = SessionManager();