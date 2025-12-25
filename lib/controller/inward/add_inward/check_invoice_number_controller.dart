import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/add_inward/get_invoice_number_response.dart';

import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/custom_flushbar.dart';

class CheckInvoiceNumberController extends GetxController {
  RxBool isLoading = true.obs;
  RxString flag = "".obs;
  Future<void> verifyInvoiceNumber({
    BuildContext? context,
    required String invNo,
    required String outwardID,
    // required String? token,
  }) async {
    try {
      final jsonBody = {"invoice_number": invNo, "outward_id": outwardID};

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.checkInvoiceNumberApi,
        Networkutility.checkInvoiceNumber,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetInvoiceNumberResponse> response = List.from(list);
        // log(response[0].data.mobileNumber);
        if (response[0].status == "true") {
          final user = response[0].flag;
          flag.value = user;
          if (user == "1") {
          
          }
        } else if (response[0].status == "false") {
          final user = response[0].flag;
          flag.value = user;
          print("======>succees");
        }
      } else {
       // Get.back();
        CustomFlushbar.flushBarErrorMessage(
          'Error',
          'No response from server',
          context!,
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } on TimeoutException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } on HttpException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        context!,
      );
    } on ParseException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        'Unexpected error: $e',
        context!,
      );
    } finally {
      isLoading.value = false;
    }
  }
}