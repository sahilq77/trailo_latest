// To parse this JSON data, do
//
//     final getCompanyResponse = getCompanyResponseFromJson(jsonString);

import 'dart:convert';

List<GetCompanyResponse> getCompanyResponseFromJson(String str) => List<GetCompanyResponse>.from(json.decode(str).map((x) => GetCompanyResponse.fromJson(x)));

String getCompanyResponseToJson(List<GetCompanyResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetCompanyResponse {
    String status;
    String message;
    List<CompanyData> data;

    GetCompanyResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetCompanyResponse.fromJson(Map<String, dynamic> json) => GetCompanyResponse(
        status: json["status"],
        message: json["message"],
        data: List<CompanyData>.from(json["data"].map((x) => CompanyData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class CompanyData {
    String companyId;
    String companyName;

    CompanyData({
        required this.companyId,
        required this.companyName,
    });

    factory CompanyData.fromJson(Map<String, dynamic> json) => CompanyData(
        companyId: json["company_id"],
        companyName: json["company_name"],
    );

    Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "company_name": companyName,
    };
}
