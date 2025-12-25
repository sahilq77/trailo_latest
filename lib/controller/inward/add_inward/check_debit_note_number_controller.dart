import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/add_inward/check_debit_note_number_response.dart';
import 'package:trailo/model/add_inward/check_vender_invoice_number_response.dart';
import 'package:trailo/model/add_inward/get_invoice_number_response.dart';

import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';

class CheckDebitNoteNumberController extends GetxController {
  RxBool isLoading = true.obs;
  RxString flag = "".obs;
  Future<void> verifyInvoiceNumber({
    BuildContext? context,
    required String invNo,
    required String inwardID,
    // required String? token,
  }) async {
    try {
      final jsonBody = {"debit_note_number": invNo, "inward_id": inwardID};

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.checkDebitNoteNumberApi,
        Networkutility.checkDebitNoteNumber,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<CheckdDebitNoteNumberResponse> response = List.from(list);
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
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Unexpected errorColor: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
