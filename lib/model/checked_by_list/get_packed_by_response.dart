// To parse this JSON data, do
//
//     final getTransferPackedResponse = getTransferPackedResponseFromJson(jsonString);

import 'dart:convert';

List<GetTransferPackedResponse> getTransferPackedResponseFromJson(String str) => List<GetTransferPackedResponse>.from(json.decode(str).map((x) => GetTransferPackedResponse.fromJson(x)));

String getTransferPackedResponseToJson(List<GetTransferPackedResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetTransferPackedResponse {
    String status;
    String message;

    GetTransferPackedResponse({
        required this.status,
        required this.message,
    });

    factory GetTransferPackedResponse.fromJson(Map<String, dynamic> json) => GetTransferPackedResponse(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
