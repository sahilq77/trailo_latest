// To parse this JSON data, do
//
//     final getSalesTeamEmployeeResponse = getSalesTeamEmployeeResponseFromJson(jsonString);

import 'dart:convert';

List<GetSalesTeamEmployeeResponse> getSalesTeamEmployeeResponseFromJson(String str) => List<GetSalesTeamEmployeeResponse>.from(json.decode(str).map((x) => GetSalesTeamEmployeeResponse.fromJson(x)));

String getSalesTeamEmployeeResponseToJson(List<GetSalesTeamEmployeeResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSalesTeamEmployeeResponse {
    String status;
    String message;
    List<SalesTeamEmployeeData> data;

    GetSalesTeamEmployeeResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetSalesTeamEmployeeResponse.fromJson(Map<String, dynamic> json) => GetSalesTeamEmployeeResponse(
        status: json["status"],
        message: json["message"],
        data: List<SalesTeamEmployeeData>.from(json["data"].map((x) => SalesTeamEmployeeData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class SalesTeamEmployeeData {
    String employeeId;
    String employeeName;

    SalesTeamEmployeeData({
        required this.employeeId,
        required this.employeeName,
    });

    factory SalesTeamEmployeeData.fromJson(Map<String, dynamic> json) => SalesTeamEmployeeData(
        employeeId: json["employee_id"],
        employeeName: json["employee_name"],
    );

    Map<String, dynamic> toJson() => {
        "employee_id": employeeId,
        "employee_name": employeeName,
    };
}
