// To parse this JSON data, do
//
//     final getInwardNumberResponse = getInwardNumberResponseFromJson(jsonString);

import 'dart:convert';

List<GetInwardNumberResponse> getInwardNumberResponseFromJson(String str) => List<GetInwardNumberResponse>.from(json.decode(str).map((x) => GetInwardNumberResponse.fromJson(x)));

String getInwardNumberResponseToJson(List<GetInwardNumberResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetInwardNumberResponse {
    String status;
    String message;
    String flag;

    GetInwardNumberResponse({
        required this.status,
        required this.message,
        required this.flag,
    });

    factory GetInwardNumberResponse.fromJson(Map<String, dynamic> json) => GetInwardNumberResponse(
        status: json["status"],
        message: json["message"],
        flag: json["flag"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "flag": flag,
    };
}
