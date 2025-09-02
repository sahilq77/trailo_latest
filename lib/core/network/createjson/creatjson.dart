import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:trailo/model/login/get_login_call.dart';
import 'package:trailo/model/login/get_login_response.dart';

class Createjson {
  String createJsonForGetLogin(String mobile, String password) {
    try {
      const encoder = JsonEncoder.withIndent('');
      final call = GetLoginCall(mobileNumber: mobile, password: password);
      final json = GetLoginCall.fromJson(call.toJson());
      return encoder.convert(json);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return "";
    }
  }
}
