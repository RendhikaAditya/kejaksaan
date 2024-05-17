import 'dart:convert';

ModelLaporan modelLaporanFromJson(String str) => ModelLaporan.fromJson(json.decode(str));

String modelLaporanToJson(ModelLaporan data) => json.encode(data.toJson());

class ModelLaporan {
  bool sukses;
  int status;
  String pesan;
  List<Datum>? data; // Mengizinkan nilai null pada data

  ModelLaporan({
    required this.sukses,
    required this.status,
    required this.pesan,
    this.data, // Tidak wajib untuk diisi
  });

  factory ModelLaporan.fromJson(Map<String, dynamic> json) => ModelLaporan(
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
  String idLaporan;
  String idUser;
  String laporanText;
  String laporanPdf;
  String status;
  String tipeLaporan;
  DateTime createdDate;

  Datum({
    required this.idLaporan,
    required this.idUser,
    required this.laporanText,
    required this.laporanPdf,
    required this.status,
    required this.tipeLaporan,
    required this.createdDate,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    idLaporan: json["id_laporan"],
    idUser: json["id_user"],
    laporanText: json["laporan_text"],
    laporanPdf: json["laporan_pdf"],
    status: json["status"],
    tipeLaporan: json["tipe_laporan"],
    createdDate: DateTime.parse(json["created_date"]),
  );

  Map<String, dynamic> toJson() => {
    "id_laporan": idLaporan,
    "id_user": idUser,
    "laporan_text": laporanText,
    "laporan_pdf": laporanPdf,
    "status": status,
    "tipe_laporan": tipeLaporan,
    "created_date": createdDate.toIso8601String(),
  };
}
