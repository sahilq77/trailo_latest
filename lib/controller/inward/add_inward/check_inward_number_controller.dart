import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/add_inward/get_invoice_number_response.dart';
import 'package:trailo/model/add_inward/get_inward_number_respons.dart';

import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';

class CheckInwardNumberController extends GetxController {
  RxBool isLoading = true.obs;
  RxString flag = "".obs;
  Future<void> verifyInwardNumber({
    BuildContext? context,
    required String inwardNo,
    required String inwardID,
    // required String? token,
  }) async {
    try {
      final jsonBody = {"inward_number": inwardNo, "inward_id": inwardID};

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.checkInwardNumberApi,
        Networkutility.checkInwardNumber,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetInwardNumberResponse> response = List.from(list);
        // log(response[0].data.mobileNumber);
        if (response[0].status == "true") {
          final user = response[0].flag;
          flag.value = user;
          //
        } else if (response[0].status == "false") {
          final user = response[0].flag;
          flag.value = user;
          print("======>succees");
        }
      } else {
        // Get.back();
        Get.snackbar(
          'Error',
          'Something Went Wrong',
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
