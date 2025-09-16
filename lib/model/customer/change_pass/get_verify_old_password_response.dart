// To parse this JSON data, do
//
//     final getVerifyOldPassResponse = getVerifyOldPassResponseFromJson(jsonString);

import 'dart:convert';

List<GetVerifyOldPassResponse> getVerifyOldPassResponseFromJson(String str) =>
    List<GetVerifyOldPassResponse>.from(
      json.decode(str).map((x) => GetVerifyOldPassResponse.fromJson(x)),
    );

String getVerifyOldPassResponseToJson(List<GetVerifyOldPassResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetVerifyOldPassResponse {
  String isCheck;
  String status;
  String message;

  GetVerifyOldPassResponse({
    required this.isCheck,
    required this.status,
    required this.message,
  });

  factory GetVerifyOldPassResponse.fromJson(Map<String, dynamic> json) =>
      GetVerifyOldPassResponse(
        isCheck: json["is_check"] ?? "",
        status: json["status"] ?? "",
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "is_check": isCheck,
    "status": status,
    "message": message,
  };
}
