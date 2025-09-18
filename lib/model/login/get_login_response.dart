// To parse this JSON data, do
//
//     final getLoginResponse = getLoginResponseFromJson(jsonString);

import 'dart:convert';

List<GetLoginResponse> getLoginResponseFromJson(String str) {
  try {
    final jsonData = json.decode(str);
    if (jsonData is List) {
      return List<GetLoginResponse>.from(
        jsonData.map(
          (x) => GetLoginResponse.fromJson(x as Map<String, dynamic>),
        ),
      );
    }
    return [];
  } catch (e) {
    // Handle JSON parsing errors gracefully
    print('Error parsing JSON: $e');
    return [];
  }
}

String getLoginResponseToJson(List<GetLoginResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLoginResponse {
  String status;
  String message;
  LoginData? data; // Made nullable to handle cases where data might be null

  GetLoginResponse({
    required this.status,
    required this.message,
    this.data, // Optional, can be null
  });

  factory GetLoginResponse.fromJson(Map<String, dynamic> json) =>
      GetLoginResponse(
        status: json["status"]?.toString() ?? "unknown",
        message: json["message"]?.toString() ?? "",
        data: json["data"] != null
            ? LoginData.fromJson(json["data"] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(), // Handle null data
  };
}

class LoginData {
  String id;
  String employeeName;
  String designationId;
  String departmentId;
  DateTime? doj; // Made nullable to handle invalid or missing dates
  String mobileNumber;
  String password;
  String userType;
  String loginType;
  String customerMobile;

  LoginData({
    required this.id,
    required this.employeeName,
    required this.designationId,
    required this.departmentId,
    this.doj, // Optional, can be null
    required this.mobileNumber,
    required this.password,
    required this.userType,
    required this.loginType,
    required this.customerMobile,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) => LoginData(
    id: json["id"]?.toString() ?? "",
    userType: json["user_type"]?.toString() ?? "",
    employeeName: json["employee_name"]?.toString() ?? "",
    designationId: json["designation_id"]?.toString() ?? "",
    departmentId: json["department_id"]?.toString() ?? "",
    doj: _parseDate(json["doj"]),
    mobileNumber: json["mobile_number"]?.toString() ?? "",
    password: json["password"]?.toString() ?? "",
    loginType: json["login_type"]?.toString() ?? "",
    customerMobile: json["mobile_number_1"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_type": userType,
    "employee_name": employeeName,
    "designation_id": designationId,
    "department_id": departmentId,
    "doj": doj != null
        ? "${doj!.year.toString().padLeft(4, '0')}-${doj!.month.toString().padLeft(2, '0')}-${doj!.day.toString().padLeft(2, '0')}"
        : null,
    "mobile_number": mobileNumber,
    "password": password,
    "login_type": loginType,
  };

  static DateTime? _parseDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return null;
    try {
      return DateTime.parse(date.toString());
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }
}
