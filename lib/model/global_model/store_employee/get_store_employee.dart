// To parse this JSON data, do
//
//     final getStoreEmployeeResponse = getStoreEmployeeResponseFromJson(jsonString);

import 'dart:convert';

List<GetStoreEmployeeResponse> getStoreEmployeeResponseFromJson(String str) => List<GetStoreEmployeeResponse>.from(json.decode(str).map((x) => GetStoreEmployeeResponse.fromJson(x)));

String getStoreEmployeeResponseToJson(List<GetStoreEmployeeResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetStoreEmployeeResponse {
    String status;
    String message;
    List<StoreEmployeeData> data;

    GetStoreEmployeeResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetStoreEmployeeResponse.fromJson(Map<String, dynamic> json) => GetStoreEmployeeResponse(
        status: json["status"],
        message: json["message"],
        data: List<StoreEmployeeData>.from(json["data"].map((x) => StoreEmployeeData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class StoreEmployeeData {
    String employeeId;
    String employeeName;
    String departmentName;
    String departmentId;

    StoreEmployeeData({
        required this.employeeId,
        required this.employeeName,
        required this.departmentName,
        required this.departmentId,
    });

    factory StoreEmployeeData.fromJson(Map<String, dynamic> json) => StoreEmployeeData(
        employeeId: json["employee_id"],
        employeeName: json["employee_name"],
        departmentName: json["department_name"],
        departmentId: json["department_id"],
    );

    Map<String, dynamic> toJson() => {
        "employee_id": employeeId,
        "employee_name": employeeName,
        "department_name": departmentName,
        "department_id": departmentId,
    };
}
