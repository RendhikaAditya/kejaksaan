import 'dart:convert';

ModelLaporanJms modelLaporanJmsFromJson(String str) => ModelLaporanJms.fromJson(json.decode(str));

String modelLaporanJmsToJson(ModelLaporanJms data) => json.encode(data.toJson());

class ModelLaporanJms {
  bool sukses;
  int status;
  String pesan;
  List<Datum>? data; // Mengizinkan data untuk bernilai null dan berisi elemen null

  ModelLaporanJms({
    required this.sukses,
    required this.status,
    required this.pesan,
    this.data, // Tidak wajib untuk diisi
  });

  factory ModelLaporanJms.fromJson(Map<String, dynamic> json) => ModelLaporanJms(
    sukses: json["sukses"],
    status: json["status"],
    pesan: json["pesan"],
    data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "sukses": sukses,
    "status": status,
    "pesan": pesan,
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())), // Tambahkan pengecekan null
  };
}

class Datum {
  String idJms;
  String idUser;
  String sekolah;
  String status;
  DateTime createdDate;

  Datum({
    required this.idJms,
    required this.idUser,
    required this.sekolah,
    required this.status,
    required this.createdDate,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    idJms: json["id_jms"],
    idUser: json["id_user"],
    sekolah: json["sekolah"],
    status: json["status"],
    createdDate: DateTime.parse(json["created_date"]),
  );

  Map<String, dynamic> toJson() => {
    "id_jms": idJms,
    "id_user": idUser,
    "sekolah": sekolah,
    "status": status,
    "created_date": createdDate.toIso8601String(),
  };
}
