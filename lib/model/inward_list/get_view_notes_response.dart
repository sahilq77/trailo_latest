// To parse this JSON data, do
//
//     final getViewNotesResponse = getViewNotesResponseFromJson(jsonString);

import 'dart:convert';

List<GetViewNotesResponse> getViewNotesResponseFromJson(String str) =>
    List<GetViewNotesResponse>.from(
      json.decode(str).map((x) => GetViewNotesResponse.fromJson(x)),
    );

String getViewNotesResponseToJson(List<GetViewNotesResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetViewNotesResponse {
  String status;
  String message;
  String documentPath;
  CreditNoteData? data;

  GetViewNotesResponse({
    required this.status,
    required this.message,
    required this.documentPath,
    this.data,
  });

  factory GetViewNotesResponse.fromJson(Map<String, dynamic> json) =>
      GetViewNotesResponse(
        status: json["status"] as String? ?? "",
        message: json["message"] as String? ?? "",
        documentPath: json["document_path"] as String? ?? "",
        data: json["data"] != null
            ? CreditNoteData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "document_path": documentPath,
    "data": data?.toJson(),
  };
}

class CreditNoteData {
  String id;
  String inwardId;
  String inwardNumber;
  String statusId;
  String mrnPreparedBy;
  String mrnCheckedBy;
  String stocksArrangedBy;
  String remark;
  String partyType;
  dynamic invoiceNumber;
  dynamic invoiceDate;
  String mrnCopy;
  String addedBy;
  String isDeleted;
  String status;
  DateTime? createdOn;
  DateTime? updatedOn;
  String customerId;
  dynamic vendorId;
  String partyName;
  List<CreditNote>? creditNotes;

  CreditNoteData({
    required this.id,
    required this.inwardId,
    required this.inwardNumber,
    required this.statusId,
    required this.mrnPreparedBy,
    required this.mrnCheckedBy,
    required this.stocksArrangedBy,
    required this.remark,
    required this.partyType,
    this.invoiceNumber,
    this.invoiceDate,
    required this.mrnCopy,
    required this.addedBy,
    required this.isDeleted,
    required this.status,
    this.createdOn,
    this.updatedOn,
    required this.customerId,
    this.vendorId,
    required this.partyName,
    this.creditNotes,
  });

  factory CreditNoteData.fromJson(Map<String, dynamic> json) => CreditNoteData(
    id: json["id"] as String? ?? "",
    inwardId: json["inward_id"] as String? ?? "",
    inwardNumber: json["inward_number"] as String? ?? "",
    statusId: json["status_id"] as String? ?? "",
    mrnPreparedBy: json["mrn_prepared_by"] as String? ?? "",
    mrnCheckedBy: json["mrn_checked_by"] as String? ?? "",
    stocksArrangedBy: json["stocks_arranged_by"] as String? ?? "",
    remark: json["remark"] as String? ?? "",
    partyType: json["party_type"] as String? ?? "",
    invoiceNumber: json["invoice_number"],
    invoiceDate: json["invoice_date"],
    mrnCopy: json["mrn_copy"] as String? ?? "",
    addedBy: json["added_by"] as String? ?? "",
    isDeleted: json["is_deleted"] as String? ?? "",
    status: json["status"] as String? ?? "",
    createdOn: json["created_on"] != null
        ? DateTime.tryParse(json["created_on"] as String)
        : null,
    updatedOn: json["updated_on"] != null
        ? DateTime.tryParse(json["updated_on"] as String)
        : null,
    customerId: json["customer_id"] as String? ?? "",
    vendorId: json["vendor_id"],
    partyName: json["party_name"] as String? ?? "",
    creditNotes: json["credit_notes"] != null
        ? List<CreditNote>.from(
            json["credit_notes"].map((x) => CreditNote.fromJson(x)),
          )
        : List<CreditNote>.from(
            json["grn_entries"].map((x) => CreditNote.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "inward_id": inwardId,
    "inward_number": inwardNumber,
    "status_id": statusId,
    "mrn_prepared_by": mrnPreparedBy,
    "mrn_checked_by": mrnCheckedBy,
    "stocks_arranged_by": stocksArrangedBy,
    "remark": remark,
    "party_type": partyType,
    "invoice_number": invoiceNumber,
    "invoice_date": invoiceDate,
    "mrn_copy": mrnCopy,
    "added_by": addedBy,
    "is_deleted": isDeleted,
    "status": status,
    "created_on": createdOn?.toIso8601String(),
    "updated_on": updatedOn?.toIso8601String(),
    "customer_id": customerId,
    "vendor_id": vendorId,
    "party_name": partyName,
    "credit_notes": creditNotes != null
        ? List<dynamic>.from(creditNotes!.map((x) => x.toJson()))
        : null,
  };
}

class CreditNote {
  String id;
  String inwardId;
  dynamic noteNumber;
  String creditNote;
  String creditNoteCopy;
  String addedBy;
  String isDeleted;
  String status;
  DateTime? createdOn;
  DateTime? updatedOn;

  CreditNote({
    required this.id,
    required this.inwardId,
    this.noteNumber,
    required this.creditNote,
    required this.creditNoteCopy,
    required this.addedBy,
    required this.isDeleted,
    required this.status,
    this.createdOn,
    this.updatedOn,
  });

  factory CreditNote.fromJson(Map<String, dynamic> json) => CreditNote(
    id: json["id"] as String? ?? "",
    inwardId: json["inward_id"] as String? ?? "",
    noteNumber: json["note_number"],
    creditNote: json["credit_note"] as String? ?? "",
    creditNoteCopy: json["credit_note_copy"] as String? ?? "",
    addedBy: json["added_by"] as String? ?? "",
    isDeleted: json["is_deleted"] as String? ?? "",
    status: json["status"] as String? ?? "",
    createdOn: json["created_on"] != null
        ? DateTime.tryParse(json["created_on"] as String)
        : null,
    updatedOn: json["updated_on"] != null
        ? DateTime.tryParse(json["updated_on"] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "inward_id": inwardId,
    "note_number": noteNumber,
    "credit_note": creditNote,
    "credit_note_copy": creditNoteCopy,
    "added_by": addedBy,
    "is_deleted": isDeleted,
    "status": status,
    "created_on": createdOn?.toIso8601String(),
    "updated_on": updatedOn?.toIso8601String(),
  };
}
