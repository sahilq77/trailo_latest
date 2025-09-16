import 'dart:convert';

List<GetCutsomerLoginResponse> getCutsomerLoginResponseFromJson(String str) =>
    List<GetCutsomerLoginResponse>.from(
      json.decode(str).map((x) => GetCutsomerLoginResponse.fromJson(x)),
    );

String getCutsomerLoginResponseToJson(List<GetCutsomerLoginResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetCutsomerLoginResponse {
  String status;
  String message;
  Data? data; // Made data nullable to handle empty or missing data

  GetCutsomerLoginResponse({
    required this.status,
    required this.message,
    this.data, // Removed required keyword since data can be null
  });

  factory GetCutsomerLoginResponse.fromJson(Map<String, dynamic> json) =>
      GetCutsomerLoginResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: json["data"] != null && json["data"].isNotEmpty
            ? Data.fromJson(json["data"])
            : null, // Set data to null if empty or missing
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson() ?? {}, // Handle null data
      };
}

class Data {
  String id;
  String customerCode;
  String customerName;
  String mobileNumber1;
  String mobileNumber2;
  String email;
  String password;
  String userType;

  Data({
    required this.id,
    required this.customerCode,
    required this.customerName,
    required this.mobileNumber1,
    required this.mobileNumber2,
    required this.email,
    required this.password,
    required this.userType,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] ?? "",
        customerCode: json["customer_code"] ?? "",
        customerName: json["customer_name"] ?? "",
        mobileNumber1: json["mobile_number_1"] ?? "",
        mobileNumber2: json["mobile_number_2"] ?? "",
        email: json["email"] ?? "",
        password: json["password"] ?? "",
        userType: json["user_type"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_code": customerCode,
        "customer_name": customerName,
        "mobile_number_1": mobileNumber1,
        "mobile_number_2": mobileNumber2,
        "email": email,
        "password": password,
        "user_type": userType,
      };
}