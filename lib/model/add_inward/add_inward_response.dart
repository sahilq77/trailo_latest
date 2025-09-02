// To parse this JSON data, do
//
//     final getAddInwardResponse = getAddInwardResponseFromJson(jsonString);

import 'dart:convert';

List<GetAddInwardResponse> getAddInwardResponseFromJson(String str) =>
    List<GetAddInwardResponse>.from(
      json.decode(str).map((x) => GetAddInwardResponse.fromJson(x)),
    );

String getAddInwardResponseToJson(List<GetAddInwardResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAddInwardResponse {
  String status;
  String message;
  String documentPath;
  Data data;

  GetAddInwardResponse({
    required this.status,
    required this.message,
    required this.documentPath,
    required this.data,
  });

  factory GetAddInwardResponse.fromJson(Map<String, dynamic> json) =>
      GetAddInwardResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        documentPath: json["document_path"] ?? "",
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "document_path": documentPath,
    "data": data.toJson(),
  };
}

class Data {
  String companyId;
  String divisionId;
  String customerId;
  String vendorId;
  String statusId;
  String transportId;
  DateTime? receiptDate; // Made nullable
  String inwardNumber;
  String entityType;
  String debitNoteNumber;
  DateTime? debitNoteDate; // Made nullable
  String vendorInvoiceNumber;
  DateTime? vendorInvoiceDate; // Changed to DateTime? for consistency
  String lrNumber;
  DateTime? lrDate; // Made nullable
  String freightAmount;
  String claim;
  dynamic lrCopy;
  dynamic debitNoteCopy;
  dynamic invoiceCopy;
  String addedBy;
  DateTime? createdOn; // Made nullable
  int inwardId;

  Data({
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
    required this.addedBy,
    this.createdOn,
    required this.inwardId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
    addedBy: json["added_by"] ?? "",
    createdOn: _parseDate(json["created_on"]),
    inwardId: json["inward_id"] ?? "", // Default to 0 for int
  );

  Map<String, dynamic> toJson() => {
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
    "added_by": addedBy,
    "created_on": createdOn?.toIso8601String(),
    "inward_id": inwardId,
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
