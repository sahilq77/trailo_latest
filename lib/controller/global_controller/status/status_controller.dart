import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/global_model/company/get_company_response.dart';
import 'package:trailo/model/global_model/divison/get_division_response.dart';
import 'package:trailo/model/global_model/status/get_status_response.dart';
import 'package:trailo/model/global_model/transport/get_all_transport_response.dart';
import 'package:trailo/utility/app_utility.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../model/global_model/customers/get_customers_response.dart';
import '../../../utility/app_colors.dart';

class StatusController extends GetxController {
  RxList<StatusData> statusList = <StatusData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedStatusVal;

  static StatusController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Defer fetching until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchStatus(context: Get.context!);
      }
    });
  }

  Future<void> fetchStatus({
    required BuildContext context,
    bool forceFetch = false,
  }) async {
    if (!forceFetch && statusList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final jsonBody = {"Employee_id": AppUtility.userID};

      List<GetStatusResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getStatusApi,
                Networkutility.getStatus,
                jsonEncode(jsonBody),
                context,
              ) as List<GetStatusResponse>?;

      log(
        'Fetch Status Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          statusList.value = response[0].data;
          log(
            'Status List Loaded: ${statusList.map((s) => "${s.statusId}: ${s.statusName}").toList()}',
          );
        } else {
          errorMessage.value = response[0].message;
          Get.snackbar(
            'Error',
            response[0].message,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch Status Exception: $e, stack: $stackTrace');
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<String> getStatusNames() {
    log(
      "Status name list: ${statusList.map((s) => s.statusName).toSet().toList()}",
    );
    return statusList.map((s) => s.statusName).toSet().toList();
  }

  String? getStatusId(String statusName) {
    log(
      "Status ID for $statusName: ${statusList.firstWhereOrNull((state) => state.statusName == statusName)?.statusId}",
    );
    return statusList
        .firstWhereOrNull((state) => state.statusName == statusName)
        ?.statusId;
  }

  String? getStatusNameById(String statusId) {
    log(
      "Status name for ID $statusId: ${statusList.firstWhereOrNull((state) => state.statusId == statusId)?.statusName}",
    );
    return statusList
        .firstWhereOrNull((state) => state.statusId == statusId)
        ?.statusName;
  }
}