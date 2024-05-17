import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth{
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<User> getCurrentUser();
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<bool?> isEmailVerified();

}

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
Future<String> signIn(String email, String password) async{
  UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(
      email: email, password: password);
  return user.user?.uid ?? "";
}

//register
Future<String> signUp(String email, String password) async{
  UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, password: password);
  return user.user?.uid ?? "";
}

//untuk mendapatkan user yang sedang login
Future<User?> getCurrentUser() async{
  User? user = await _firebaseAuth.currentUser;
  return user;
}

//logout
Future<void> signOut(){
  return _firebaseAuth.signOut();
}

//kirim email verifikasi
Future<void> sendEmailVerification() async{
  User? user = await _firebaseAuth.currentUser;
  user?.sendEmailVerification();
}

//pengecekan apakah email sudah terverfikasi atau belum
Future<bool?> isEmailVerified() async{
  User? user = await _firebaseAuth.currentUser;
  return user?.emailVerified;
}