// To parse this JSON data, do
//
//     final getDeleteOutwardResponse = getDeleteOutwardResponseFromJson(jsonString);

import 'dart:convert';

List<GetDeleteOutwardResponse> getDeleteOutwardResponseFromJson(String str) => List<GetDeleteOutwardResponse>.from(json.decode(str).map((x) => GetDeleteOutwardResponse.fromJson(x)));

String getDeleteOutwardResponseToJson(List<GetDeleteOutwardResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDeleteOutwardResponse {
    String status;
    String message;

    GetDeleteOutwardResponse({
        required this.status,
        required this.message,
    });

    factory GetDeleteOutwardResponse.fromJson(Map<String, dynamic> json) => GetDeleteOutwardResponse(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
