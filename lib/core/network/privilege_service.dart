import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trailo/utility/app_utility.dart';

import '../../model/privilege/privilege_response.dart';
import '../urls.dart';

class PrivilegeService {
  Future<PrivilegeResponse?> fetchPrivileges(BuildContext context) async {
    try {
      log('Fetching privileges for user ID: ${AppUtility.userID}');

      final response = await http.post(
        Uri.parse(Networkutility.get_previlege_api),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'employee_id': AppUtility.userID}),
      );
      log(
        "URL :${Networkutility.get_previlege_api} \nRequest Body : ${jsonEncode({'employee_id': AppUtility.userID})}",
      );
      log('Privilege API response status: ${response.statusCode}');
      log('Privilege API response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final privilegeResponse = PrivilegeResponse.fromJson(jsonData);

        if (privilegeResponse.status == 'true') {
          log('Privileges retrieved successfully: ${privilegeResponse.data}');
          return privilegeResponse;
        } else {
          log('Privilege API error: ${privilegeResponse.message}');
          // Utils.flushBarErrorMessage(
          //   'Error: ${privilegeResponse.message}',
          //   context,
          //   status: 'e',
          // );
          return null;
        }
      } else {
        log('Privilege API failed with status: ${response.statusCode}');
        // Utils.flushBarErrorMessage(
        //   'Error: Failed to fetch privileges',
        //   context,
        //   status: 'e',
        // );
        return null;
      }
    } catch (e) {
      log('Error fetching privileges: $e');
      // Utils.flushBarErrorMessage(
      //   'Error: Failed to fetch privileges: $e',
      //   context,
      //   status: 'e',
      // );
      return null;
    }
  }
}
