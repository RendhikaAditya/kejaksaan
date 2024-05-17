import 'dart:convert';

ModelUser modelUserFromJson(String str) => ModelUser.fromJson(json.decode(str));

String modelUserToJson(ModelUser data) => json.encode(data.toJson());

class ModelUser {
  bool sukses;
  int status;
  String pesan;
  Data? data; // Mengizinkan data untuk bernilai null

  ModelUser({
    required this.sukses,
    required this.status,
    required this.pesan,
    this.data, // Tidak wajib untuk diisi
  });

  factory ModelUser.fromJson(Map<String, dynamic> json) => ModelUser(
    sukses: json["sukses"],
    status: json["status"],
    pesan: json["pesan"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "sukses": sukses,
    "status": status,
    "pesan": pesan,
    "data": data?.toJson(), // Menggunakan null-aware operator
  };
}

class Data {
  String idUser;
  String nama;
  String email;
  String noTelpon;
  String ktp;
  String alamat;
  String password;
  String level;
  DateTime createdDate;

  Data({
    required this.idUser,
    required this.nama,
    required this.email,
    required this.noTelpon,
    required this.ktp,
    required this.alamat,
    required this.password,
    required this.level,
    required this.createdDate,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    idUser: json["id_user"],
    nama: json["nama"],
    email: json["email"],
    noTelpon: json["no_telpon"],
    ktp: json["ktp"],
    alamat: json["alamat"],
    password: json["password"],
    level: json["level"],
    createdDate: DateTime.parse(json["created_date"]),
  );

  Map<String, dynamic> toJson() => {
    "id_user": idUser,
    "nama": nama,
    "email": email,
    "no_telpon": noTelpon,
    "ktp": ktp,
    "alamat": alamat,
    "password": password,
    "level": level,
    "created_date": createdDate.toIso8601String(),
  };
}
