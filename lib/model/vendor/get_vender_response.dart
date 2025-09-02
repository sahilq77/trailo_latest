// To parse this JSON data, do
//
//     final getVendorsResponse = getVendorsResponseFromJson(jsonString);

import 'dart:convert';

List<GetVendorsResponse> getVendorsResponseFromJson(String str) =>
    List<GetVendorsResponse>.from(
      json.decode(str).map((x) => GetVendorsResponse.fromJson(x)),
    );

String getVendorsResponseToJson(List<GetVendorsResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetVendorsResponse {
  String status;
  String message;
  List<VendorData> data;

  GetVendorsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetVendorsResponse.fromJson(Map<String, dynamic> json) =>
      GetVendorsResponse(
        status: json["status"],
        message: json["message"],
        data: List<VendorData>.from(
          json["data"].map((x) => VendorData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class VendorData {
  String vendorId;
  String vendorName;

  VendorData({required this.vendorId, required this.vendorName});

  factory VendorData.fromJson(Map<String, dynamic> json) => VendorData(
    vendorId: json["vendor_id"] ?? "",
    vendorName: json["vendor_name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "vendor_id": vendorId,
    "vendor_name": vendorName,
  };
}
