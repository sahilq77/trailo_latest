// To parse this JSON data, do
//
//     final getInvoiceNumberResponse = getInvoiceNumberResponseFromJson(jsonString);

import 'dart:convert';

List<GetInvoiceNumberResponse> getInvoiceNumberResponseFromJson(String str) => List<GetInvoiceNumberResponse>.from(json.decode(str).map((x) => GetInvoiceNumberResponse.fromJson(x)));

String getInvoiceNumberResponseToJson(List<GetInvoiceNumberResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetInvoiceNumberResponse {
    String status;
    String message;
    String flag;

    GetInvoiceNumberResponse({
        required this.status,
        required this.message,
        required this.flag,
    });

    factory GetInvoiceNumberResponse.fromJson(Map<String, dynamic> json) => GetInvoiceNumberResponse(
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
