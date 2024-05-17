// To parse this JSON data, do
//
//     final modelBase = modelBaseFromJson(jsonString);

import 'dart:convert';

ModelBase modelBaseFromJson(String str) => ModelBase.fromJson(json.decode(str));

String modelBaseToJson(ModelBase data) => json.encode(data.toJson());

class ModelBase {
  bool sukses;
  int status;
  String pesan;

  ModelBase({
    required this.sukses,
    required this.status,
    required this.pesan,
  });

  factory ModelBase.fromJson(Map<String, dynamic> json) => ModelBase(
    sukses: json["sukses"],
    status: json["status"],
    pesan: json["pesan"],
  );

  Map<String, dynamic> toJson() => {
    "sukses": sukses,
    "status": status,
    "pesan": pesan,
  };
}
