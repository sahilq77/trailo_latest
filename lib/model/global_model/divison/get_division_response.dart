// To parse this JSON data, do
//
//     final getDivisonResponse = getDivisonResponseFromJson(jsonString);

import 'dart:convert';

List<GetDivisonResponse> getDivisonResponseFromJson(String str) => List<GetDivisonResponse>.from(json.decode(str).map((x) => GetDivisonResponse.fromJson(x)));

String getDivisonResponseToJson(List<GetDivisonResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDivisonResponse {
    String status;
    String message;
    List<DivisionData> data;

    GetDivisonResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetDivisonResponse.fromJson(Map<String, dynamic> json) => GetDivisonResponse(
        status: json["status"],
        message: json["message"],
        data: List<DivisionData>.from(json["data"].map((x) => DivisionData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class DivisionData {
    String divisionId;
    String divisionName;

    DivisionData({
        required this.divisionId,
        required this.divisionName,
    });

    factory DivisionData.fromJson(Map<String, dynamic> json) => DivisionData(
        divisionId: json["division_id"],
        divisionName: json["division_name"],
    );

    Map<String, dynamic> toJson() => {
        "division_id": divisionId,
        "division_name": divisionName,
    };
}
