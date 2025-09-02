// To parse this JSON data, do
//
//     final getCustomersResponse = getCustomersResponseFromJson(jsonString);

import 'dart:convert';

List<GetCustomersResponse> getCustomersResponseFromJson(String str) => List<GetCustomersResponse>.from(json.decode(str).map((x) => GetCustomersResponse.fromJson(x)));

String getCustomersResponseToJson(List<GetCustomersResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetCustomersResponse {
    String status;
    String message;
    List<CustomersData> data;

    GetCustomersResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetCustomersResponse.fromJson(Map<String, dynamic> json) => GetCustomersResponse(
        status: json["status"],
        message: json["message"],
        data: List<CustomersData>.from(json["data"].map((x) => CustomersData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class CustomersData {
    String customerId;
    String customerName;

    CustomersData({
        required this.customerId,
        required this.customerName,
    });

    factory CustomersData.fromJson(Map<String, dynamic> json) => CustomersData(
        customerId: json["customer_id"],
        customerName: json["customer_name"],
    );

    Map<String, dynamic> toJson() => {
        "customer_id": customerId,
        "customer_name": customerName,
    };
}
