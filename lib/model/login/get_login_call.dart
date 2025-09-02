import 'dart:convert';

GetLoginCall loginFromJson(String str) => GetLoginCall.fromJson(json.decode(str));

String loginToJson(GetLoginCall data) => json.encode(data.toJson());

class GetLoginCall {
  final String mobileNumber;
  final String password;

  GetLoginCall({
    required this.mobileNumber,
    required this.password,
  });

  factory GetLoginCall.fromJson(Map<String, dynamic> json) => GetLoginCall(
        mobileNumber: json["mobile_number"] ?? "",
        password: json["password"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "mobile_number": mobileNumber,
        "password": password,
      };
}