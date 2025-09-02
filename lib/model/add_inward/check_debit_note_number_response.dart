// To parse this JSON data, do
//
//     final getInvoiceNumberResponse = getInvoiceNumberResponseFromJson(jsonString);

import 'dart:convert';

List<CheckdDebitNoteNumberResponse> getDebitNoteNumberResponseFromJson(String str) => List<CheckdDebitNoteNumberResponse>.from(json.decode(str).map((x) => CheckdDebitNoteNumberResponse.fromJson(x)));

String getInvoiceNumberResponseToJson(List<CheckdDebitNoteNumberResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CheckdDebitNoteNumberResponse {
    String status;
    String message;
    String flag;

    CheckdDebitNoteNumberResponse({
        required this.status,
        required this.message,
        required this.flag,
    });

    factory CheckdDebitNoteNumberResponse.fromJson(Map<String, dynamic> json) => CheckdDebitNoteNumberResponse(
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
