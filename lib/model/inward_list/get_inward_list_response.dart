// To parse this JSON data, do
//
//     final getInwardListResponse = getInwardListResponseFromJson(jsonString);

import 'dart:convert';

List<GetInwardListResponse> getInwardListResponseFromJson(String str) =>
    List<GetInwardListResponse>.from(
      json.decode(str).map((x) => GetInwardListResponse.fromJson(x)),
    );

String getInwardListResponseToJson(List<GetInwardListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetInwardListResponse {
  String status;
  String message;
  String documentPath;
  List<InwardListData> data;

  GetInwardListResponse({
    required this.status,
    required this.message,
    required this.documentPath,
    required this.data,
  });

  factory GetInwardListResponse.fromJson(Map<String, dynamic> json) =>
      GetInwardListResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        documentPath: json["document_path"] ?? "",
        data: List<InwardListData>.from(
          json["data"].map((x) => InwardListData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "document_path": documentPath,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class InwardListData {
  String id;
  String companyId;
  String divisionId;
  String customerId;
  String vendorId;
  String statusId;
  String transportId;
  DateTime? receiptDate; // Make nullable
  String inwardNumber;
  String entityType;
  String debitNoteNumber;
  DateTime? debitNoteDate; // Make nullable
  String vendorInvoiceNumber;
  DateTime? vendorInvoiceDate; // Make nullable
  String lrNumber;
  DateTime? lrDate; // Make nullable
  String freightAmount;
  String claim;
  String lrCopy;
  String debitNoteCopy;
  String invoiceCopy;
  String isVerified;
  String addedBy;
  String isDeleted;
  String status;
  DateTime? createdOn; // Make nullable
  DateTime? updatedOn; // Make nullable
  String companyName;
  String divisionName;
  dynamic customerName;
  String vendorName;
  String statusName;
  String transportName;

  InwardListData({
    required this.id,
    required this.companyId,
    required this.divisionId,
    required this.customerId,
    required this.vendorId,
    required this.statusId,
    required this.transportId,
    this.receiptDate,
    required this.inwardNumber,
    required this.entityType,
    required this.debitNoteNumber,
    this.debitNoteDate,
    required this.vendorInvoiceNumber,
    this.vendorInvoiceDate,
    required this.lrNumber,
    this.lrDate,
    required this.freightAmount,
    required this.claim,
    required this.lrCopy,
    required this.debitNoteCopy,
    required this.invoiceCopy,
    required this.isVerified,
    required this.addedBy,
    required this.isDeleted,
    required this.status,
    this.createdOn,
    this.updatedOn,
    required this.companyName,
    required this.divisionName,
    required this.customerName,
    required this.vendorName,
    required this.statusName,
    required this.transportName,
  });

  factory InwardListData.fromJson(Map<String, dynamic> json) => InwardListData(
    id: json["id"] ?? "",
    companyId: json["company_id"] ?? "",
    divisionId: json["division_id"] ?? "",
    customerId: json["customer_id"] ?? "",
    vendorId: json["vendor_id"] ?? "",
    statusId: json["status_id"] ?? "",
    transportId: json["transport_id"] ?? "",
    receiptDate: _parseDate(json["receipt_date"]),
    inwardNumber: json["inward_number"] ?? "",
    entityType: json["entity_type"] ?? "",
    debitNoteNumber: json["debit_note_number"] ?? "",
    debitNoteDate: _parseDate(json["debit_note_date"]),
    vendorInvoiceNumber: json["vendor_invoice_number"] ?? "",
    vendorInvoiceDate: _parseDate(json["vendor_invoice_date"]),
    lrNumber: json["lr_number"] ?? "",
    lrDate: _parseDate(json["lr_date"]),
    freightAmount: json["freight_amount"] ?? "",
    claim: json["claim"] ?? "",
    lrCopy: json["lr_copy"] ?? "",
    debitNoteCopy: json["debit_note_copy"] ?? "",
    invoiceCopy: json["invoice_copy"] ?? "",
    isVerified: json["is_verified"] ?? "",
    addedBy: json["added_by"] ?? "",
    isDeleted: json["is_deleted"] ?? "",
    status: json["status"] ?? "",
    createdOn: _parseDate(json["created_on"]),
    updatedOn: _parseDate(json["updated_on"]),
    companyName: json["company_name"] ?? "",
    divisionName: json["division_name"] ?? "",
    customerName: json["customer_name"] ?? "",
    vendorName: json["vendor_name"] ?? "",
    statusName: json["status_name"] ?? "",
    transportName: json["transport_name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "company_id": companyId,
    "division_id": divisionId,
    "customer_id": customerId,
    "vendor_id": vendorId,
    "status_id": statusId,
    "transport_id": transportId,
    "receipt_date": receiptDate != null
        ? "${receiptDate!.year.toString().padLeft(4, '0')}-${receiptDate!.month.toString().padLeft(2, '0')}-${receiptDate!.day.toString().padLeft(2, '0')}"
        : null,
    "inward_number": inwardNumber,
    "entity_type": entityType,
    "debit_note_number": debitNoteNumber,
    "debit_note_date": debitNoteDate != null
        ? "${debitNoteDate!.year.toString().padLeft(4, '0')}-${debitNoteDate!.month.toString().padLeft(2, '0')}-${debitNoteDate!.day.toString().padLeft(2, '0')}"
        : null,
    "vendor_invoice_number": vendorInvoiceNumber,
    "vendor_invoice_date": vendorInvoiceDate != null
        ? "${vendorInvoiceDate!.year.toString().padLeft(4, '0')}-${vendorInvoiceDate!.month.toString().padLeft(2, '0')}-${vendorInvoiceDate!.day.toString().padLeft(2, '0')}"
        : null,
    "lr_number": lrNumber,
    "lr_date": lrDate != null
        ? "${lrDate!.year.toString().padLeft(4, '0')}-${lrDate!.month.toString().padLeft(2, '0')}-${lrDate!.day.toString().padLeft(2, '0')}"
        : null,
    "freight_amount": freightAmount,
    "claim": claim,
    "lr_copy": lrCopy,
    "debit_note_copy": debitNoteCopy,
    "invoice_copy": invoiceCopy,
    "is_verified": isVerified,
    "added_by": addedBy,
    "is_deleted": isDeleted,
    "status": status,
    "created_on": createdOn?.toIso8601String(),
    "updated_on": updatedOn?.toIso8601String(),
    "company_name": companyName,
    "division_name": divisionName,
    "customer_name": customerName,
    "vendor_name": vendorName,
    "status_name": statusName,
    "transport_name": transportName,
  };

  // Helper method to parse DateTime safely
  static DateTime? _parseDate(dynamic date) {
    if (date == null || date == "") return null;
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null; // Return null if parsing fails
    }
  }
}
