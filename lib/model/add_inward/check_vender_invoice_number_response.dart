// To parse this JSON data, do
//
//     final getInvoiceNumberResponse = getInvoiceNumberResponseFromJson(jsonString);

import 'dart:convert';

List<CheckVenderInvoiceNumberResponse> getVenderInvoiceNumberResponseFromJson(String str) => List<CheckVenderInvoiceNumberResponse>.from(json.decode(str).map((x) => CheckVenderInvoiceNumberResponse.fromJson(x)));

String getInvoiceNumberResponseToJson(List<CheckVenderInvoiceNumberResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CheckVenderInvoiceNumberResponse {
    String status;
    String message;
    String flag;

    CheckVenderInvoiceNumberResponse({
        required this.status,
        required this.message,
        required this.flag,
    });

    factory CheckVenderInvoiceNumberResponse.fromJson(Map<String, dynamic> json) => CheckVenderInvoiceNumberResponse(
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
