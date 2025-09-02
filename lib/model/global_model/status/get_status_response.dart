// To parse this JSON data, do
//
//     final getStatusResponse = getStatusResponseFromJson(jsonString);

import 'dart:convert';

List<GetStatusResponse> getStatusResponseFromJson(String str) => List<GetStatusResponse>.from(json.decode(str).map((x) => GetStatusResponse.fromJson(x)));

String getStatusResponseToJson(List<GetStatusResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetStatusResponse {
    String status;
    String message;
    List<StatusData> data;

    GetStatusResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetStatusResponse.fromJson(Map<String, dynamic> json) => GetStatusResponse(
        status: json["status"],
        message: json["message"],
        data: List<StatusData>.from(json["data"].map((x) => StatusData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class StatusData {
    String statusId;
    String statusName;

    StatusData({
        required this.statusId,
        required this.statusName,
    });

    factory StatusData.fromJson(Map<String, dynamic> json) => StatusData(
        statusId: json["status_id"],
        statusName: json["status_name"],
    );

    Map<String, dynamic> toJson() => {
        "status_id": statusId,
        "status_name": statusName,
    };
}
