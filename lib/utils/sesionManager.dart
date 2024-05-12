import 'package:shared_preferences/shared_preferences.dart';

class SessionManager{
  bool? value;
  String? idUser;
  String? userName;
  String? fullname;
  String? alamat;
  String? nohp;

  //simpan sesi
  Future<void> saveSession(bool val, String id, String userName, String fullName, String alamat, String nohp) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool("sukses", val);
    pref.setString("id_user", id);
    pref.setString("username", userName);
    pref.setString("nama_user", fullName);
    pref.setString("alamat_user", alamat);
    pref.setString("nohp_user", nohp);
  }

  Future getSession() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    value = pref.getBool("sukses");
    idUser = pref.getString("id_user");
    userName = pref.getString("username");
    fullname = pref.getString("nama_user");
    alamat =  pref.getString("alamat_user");
    nohp = pref.getString("nohp_user");
  }
  //remove --> logout
  Future clearSession() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

}

//instance class biar d panggil
SessionManager sessionManager = SessionManager();