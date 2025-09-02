// To parse this JSON data, do
//
//     final getOutwardListResponse = getOutwardListResponseFromJson(jsonString);

import 'dart:convert';

List<GetOutwardListResponse> getOutwardListResponseFromJson(String str) {
  try {
    final decoded = json.decode(str);
    if (decoded is List) {
      return List<GetOutwardListResponse>.from(
        decoded.map(
          (x) => GetOutwardListResponse.fromJson(x as Map<String, dynamic>),
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

String getOutwardListResponseToJson(List<GetOutwardListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetOutwardListResponse {
  String status;
  String message;
  String documentPath;
  List<OutwardListData> data;

  GetOutwardListResponse({
    required this.status,
    required this.message,
    required this.documentPath,
    required this.data,
  });

  factory GetOutwardListResponse.fromJson(Map<String, dynamic> json) {
    return GetOutwardListResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      documentPath: json['document_path'] as String? ?? '',
      data: json['data'] is List
          ? List<OutwardListData>.from(
              (json['data'] as List).map(
                (x) => OutwardListData.fromJson(x as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'document_path': documentPath,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class OutwardListData {
  String id;
  String companyId;
  String divisionId;
  String processType;
  String statusId;
  String customerId;
  String salesTeamEmployeeId;
  DateTime? outwordDate; // Made nullable
  dynamic receiptDate;
  DateTime? orderDate; // Made nullable
  DateTime? invoiceDateProcess; // Made nullable
  String invoiceNumberProcess;
  String orderCopy;
  String invoiceCopyNew;
  String verificationStatus;
  dynamic weight;
  dynamic numOfCases;
  dynamic reason;
  String addedBy;
  String generatedBy;
  String isDeleted;
  String status;
  DateTime? createdOn; // Made nullable
  DateTime? updatedOn; // Made nullable
  String companyName;
  String divisionName;
  String customerName;
  String? salesTeamEmployeeName; // Made nullable
  String statusName;
  String name;
  String employeeName;
  String salesEmployeeName;

  OutwardListData({
    required this.id,
    required this.companyId,
    required this.divisionId,
    required this.processType,
    required this.statusId,
    required this.customerId,
    required this.salesTeamEmployeeId,
    this.outwordDate, // Nullable
    this.receiptDate,
    this.orderDate, // Nullable
    this.invoiceDateProcess, // Nullable
    required this.invoiceNumberProcess,
    required this.orderCopy,
    required this.invoiceCopyNew,
    required this.verificationStatus,
    this.weight,
    this.numOfCases,
    this.reason,
    required this.addedBy,
    required this.generatedBy,
    required this.isDeleted,
    required this.status,
    this.createdOn, // Nullable
    this.updatedOn, // Nullable
    required this.companyName,
    required this.divisionName,
    required this.customerName,
    this.salesTeamEmployeeName, // Nullable
    required this.statusName,
    required this.name,
    required this.employeeName,
    required this.salesEmployeeName,
  });

  factory OutwardListData.fromJson(Map<String, dynamic> json) {
    return OutwardListData(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      divisionId: json['division_id'] as String? ?? '',
      processType: json['process_type'] as String? ?? '',
      statusId: json['status_id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      salesTeamEmployeeId: json['sales_team_employee_id'] as String? ?? '',
      outwordDate: json['outword_date'] != null
          ? _parseDateTime(json['outword_date'] as String?)
          : null,
      receiptDate: json['receipt_date'],
      orderDate: json['order_date'] != null
          ? _parseDateTime(json['order_date'] as String?)
          : null,
      invoiceDateProcess: json['invoice_date_process'] != null
          ? _parseDateTime(json['invoice_date_process'] as String?)
          : null,
      invoiceNumberProcess: json['invoice_number_process'] as String? ?? '',
      orderCopy: json['order_copy'] as String? ?? '',
      invoiceCopyNew: json['invoice_copy_new'] as String? ?? '',
      verificationStatus: json['verification_status'] as String? ?? '',
      weight: json['weight'],
      numOfCases: json['num_of_cases'],
      reason: json['reason'],
      addedBy: json['added_by'] as String? ?? '',
      generatedBy: json['generated_by'] as String? ?? '',
      isDeleted: json['is_deleted'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdOn: json['created_on'] != null
          ? _parseDateTime(json['created_on'] as String?)
          : null,
      updatedOn: json['updated_on'] != null
          ? _parseDateTime(json['updated_on'] as String?)
          : null,
      companyName: json['company_name'] as String? ?? '',
      divisionName: json['division_name'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      salesTeamEmployeeName: json['sales_team_employee_name'] as String?,
      statusName: json['status_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      employeeName: json['employee_name'] as String? ?? '',
      salesEmployeeName: json['sales_employee'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'company_id': companyId,
    'division_id': divisionId,
    'process_type': processType,
    'status_id': statusId,
    'customer_id': customerId,
    'sales_team_employee_id': salesTeamEmployeeId,
    'outword_date': outwordDate?.toIso8601String(),
    'receipt_date': receiptDate,
    'order_date': orderDate?.toIso8601String(),
    'invoice_date_process': invoiceDateProcess?.toIso8601String(),
    'invoice_number_process': invoiceNumberProcess,
    'order_copy': orderCopy,
    'invoice_copy_new': invoiceCopyNew,
    'verification_status': verificationStatus,
    'weight': weight,
    'num_of_cases': numOfCases,
    'reason': reason,
    'added_by': addedBy,
    'generated_by': generatedBy,
    'is_deleted': isDeleted,
    'status': status,
    'created_on': createdOn?.toIso8601String(),
    'updated_on': updatedOn?.toIso8601String(),
    'company_name': companyName,
    'division_name': divisionName,
    'customer_name': customerName,
    'sales_team_employee_name': salesTeamEmployeeName,
    'status_name': statusName,
    'name': name,
    'employee_name': employeeName,
    'sales_employee': salesEmployeeName,
  };

  // Helper method to parse DateTime safely
  static DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print('Error parsing date: $dateStr, $e');
      return null;
    }
  }
}
