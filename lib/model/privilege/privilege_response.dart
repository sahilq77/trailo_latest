// lib/model/privilege/privilege_response.dart

class PrivilegeResponse {
  final String status;
  final String message;
  final List<String> data;

  PrivilegeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory PrivilegeResponse.fromJson(Map<String, dynamic> json) {
    return PrivilegeResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: List<String>.from(json['data'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}