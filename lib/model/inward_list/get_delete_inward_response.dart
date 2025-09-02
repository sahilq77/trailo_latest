// To parse this JSON data, do
//
//     final getDeleteInwardResponse = getDeleteInwardResponseFromJson(jsonString);

import 'dart:convert';

List<GetDeleteInwardResponse> getDeleteInwardResponseFromJson(String str) =>
    List<GetDeleteInwardResponse>.from(
      json.decode(str).map((x) => GetDeleteInwardResponse.fromJson(x)),
    );

String getDeleteInwardResponseToJson(List<GetDeleteInwardResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDeleteInwardResponse {
  String status;
  String message;

  GetDeleteInwardResponse({required this.status, required this.message});

  factory GetDeleteInwardResponse.fromJson(Map<String, dynamic> json) =>
      GetDeleteInwardResponse(status: json["status"], message: json["message"]);

  Map<String, dynamic> toJson() => {"status": status, "message": message};
}
