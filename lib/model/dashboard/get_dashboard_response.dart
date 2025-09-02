import 'dart:convert';

List<GetDashboardResponse> getDashboardResponseFromJson(String str) =>
    List<GetDashboardResponse>.from(
      json.decode(str).map((x) => GetDashboardResponse.fromJson(x)),
    );

String getDashboardResponseToJson(List<GetDashboardResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetDashboardResponse {
  String status;
  String message;
  DashboardData data;

  GetDashboardResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetDashboardResponse.fromJson(Map<String, dynamic> json) =>
      GetDashboardResponse(
        status: json["status"] ?? "", // Default to empty string if null
        message: json["message"] ?? "", // Default to empty string if null
        data: DashboardData.fromJson(
          json["data"] ?? {},
        ), // Default to empty map if null
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class DashboardData {
  String noOfDispatch;
  String noOfPendingOverdue;
  String noOfCompleted;
  String sumOfFreightAmountOne; // Changed from dynamic to String
  String sumOfFreightAmountTwo; // Changed from dynamic to String
  String noOfInvoice;
  String claim;
  String unclaim;
  String delayInInvoicing;
  String delayInDispatch;
  String delayInDelivery;

  DashboardData({
    required this.noOfDispatch,
    required this.noOfPendingOverdue,
    required this.noOfCompleted,
    required this.sumOfFreightAmountOne,
    required this.sumOfFreightAmountTwo,
    required this.noOfInvoice,
    required this.claim,
    required this.unclaim,
    required this.delayInInvoicing,
    required this.delayInDispatch,
    required this.delayInDelivery,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    noOfDispatch:
        json["no_of_dispatch"]?.toString() ??
        "0", // Convert to string, default to "0"
    noOfPendingOverdue: json["no_of_pending_overdue"]?.toString() ?? "0",
    noOfCompleted: json["no_of_completed"]?.toString() ?? "0",
    sumOfFreightAmountOne: json["sum_of_freight_amount_one"]?.toString() ?? "",
    sumOfFreightAmountTwo: json["sum_of_freight_amount_two"]?.toString() ?? "",
    noOfInvoice: json["no_of_invoice"]?.toString() ?? "0",
    claim: json["claim"]?.toString() ?? "0",
    unclaim: json["unclaim"]?.toString() ?? "0",
    delayInInvoicing: json["delay_in_invoicing"]?.toString() ?? "0",
    delayInDispatch: json["delay_in_dispatch"]?.toString() ?? "0",
    delayInDelivery: json["delay_in_delivery"]?.toString() ?? "0",
  );

  Map<String, dynamic> toJson() => {
    "no_of_dispatch": noOfDispatch,
    "no_of_pending_overdue": noOfPendingOverdue,
    "no_of_completed": noOfCompleted,
    "sum_of_freight_amount_one": sumOfFreightAmountOne,
    "sum_of_freight_amount_two": sumOfFreightAmountTwo,
    "no_of_invoice": noOfInvoice,
    "claim": claim,
    "unclaim": unclaim,
    "delay_in_invoicing": delayInInvoicing,
    "delay_in_dispatch": delayInDispatch,
    "delay_in_delivery": delayInDelivery,
  };
}
