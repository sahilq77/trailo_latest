// To parse this JSON data, do
//
//     final getTransferToCheckedResponse = getTransferToCheckedResponseFromJson(jsonString);

import 'dart:convert';

List<GetTransferToCheckedResponse> getTransferToCheckedResponseFromJson(String str) => List<GetTransferToCheckedResponse>.from(json.decode(str).map((x) => GetTransferToCheckedResponse.fromJson(x)));

String getTransferToCheckedResponseToJson(List<GetTransferToCheckedResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetTransferToCheckedResponse {
    String status;
    String message;

    GetTransferToCheckedResponse({
        required this.status,
        required this.message,
    });

    factory GetTransferToCheckedResponse.fromJson(Map<String, dynamic> json) => GetTransferToCheckedResponse(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
