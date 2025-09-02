// To parse this JSON data, do
//
//     final getAllTrasnsportResponse = getAllTrasnsportResponseFromJson(jsonString);

import 'dart:convert';

List<GetAllTrasnsportResponse> getAllTrasnsportResponseFromJson(String str) => List<GetAllTrasnsportResponse>.from(json.decode(str).map((x) => GetAllTrasnsportResponse.fromJson(x)));

String getAllTrasnsportResponseToJson(List<GetAllTrasnsportResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllTrasnsportResponse {
    String status;
    String message;
    List<TransportData> data;

    GetAllTrasnsportResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetAllTrasnsportResponse.fromJson(Map<String, dynamic> json) => GetAllTrasnsportResponse(
        status: json["status"],
        message: json["message"],
        data: List<TransportData>.from(json["data"].map((x) => TransportData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class TransportData {
    String transportId;
    String transportName;

    TransportData({
        required this.transportId,
        required this.transportName,
    });

    factory TransportData.fromJson(Map<String, dynamic> json) => TransportData(
        transportId: json["transport_id"],
        transportName: json["transport_name"],
    );

    Map<String, dynamic> toJson() => {
        "transport_id": transportId,
        "transport_name": transportName,
    };
}
