// To parse this JSON data, do
//
//     final getChangeResponse = getChangeResponseFromJson(jsonString);

import 'dart:convert';

List<GetChangeResponse> getChangeResponseFromJson(String str) => List<GetChangeResponse>.from(json.decode(str).map((x) => GetChangeResponse.fromJson(x)));

String getChangeResponseToJson(List<GetChangeResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetChangeResponse {
    String status;
    String message;

    GetChangeResponse({
        required this.status,
        required this.message,
    });

    factory GetChangeResponse.fromJson(Map<String, dynamic> json) => GetChangeResponse(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
