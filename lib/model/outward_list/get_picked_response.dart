// To parse this JSON data, do
//
//     final getPickedResponse = getPickedResponseFromJson(jsonString);

import 'dart:convert';

List<GetPickedResponse> getPickedResponseFromJson(String str) => List<GetPickedResponse>.from(json.decode(str).map((x) => GetPickedResponse.fromJson(x)));

String getPickedResponseToJson(List<GetPickedResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPickedResponse {
    String status;
    String message;

    GetPickedResponse({
        required this.status,
        required this.message,
    });

    factory GetPickedResponse.fromJson(Map<String, dynamic> json) => GetPickedResponse(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
