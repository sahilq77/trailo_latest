// To parse this JSON data, do
//
//     final getAllEmployeeResponse = getAllEmployeeResponseFromJson(jsonString);

import 'dart:convert';

List<GetAllEmployeeResponse> getAllEmployeeResponseFromJson(String str) => List<GetAllEmployeeResponse>.from(json.decode(str).map((x) => GetAllEmployeeResponse.fromJson(x)));

String getAllEmployeeResponseToJson(List<GetAllEmployeeResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAllEmployeeResponse {
    String status;
    String message;
    List<EmployeeData> data;

    GetAllEmployeeResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetAllEmployeeResponse.fromJson(Map<String, dynamic> json) => GetAllEmployeeResponse(
        status: json["status"],
        message: json["message"],
        data: List<EmployeeData>.from(json["data"].map((x) => EmployeeData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class EmployeeData {
    String employeeId;
    String employeeName;

    EmployeeData({
        required this.employeeId,
        required this.employeeName,
    });

    factory EmployeeData.fromJson(Map<String, dynamic> json) => EmployeeData(
        employeeId: json["employee_id"],
        employeeName: json["employee_name"],
    );

    Map<String, dynamic> toJson() => {
        "employee_id": employeeId,
        "employee_name": employeeName,
    };
}
