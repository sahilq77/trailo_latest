import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/dashboard/get_dashboard_response.dart';
import 'package:trailo/model/inward_list/get_inward_list_response.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/view/inward/inward_list.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/inward_list/get_delete_inward_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class DashboardController extends GetxController {
  var dashboard = <DashboardData>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxString totalInwards = "".obs;
  RxString receivedInwards = "".obs;
  RxString url = "".obs;

  // Store filter parameters
  RxString selectedCompanyId = "".obs;
  RxString selectedDivisionId = "".obs;
  RxString selectedTransportId = "".obs;
  RxString selectedMonth = "".obs;
  RxInt selectedYear = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInwardList(context: Get.context!);
  }

  Future<void> fetchInwardList({
    required BuildContext context,
    bool reset = false,
    bool forceFetch = false,
    String? companyId,
    String? divisionId,
    String? transportId,
    String? month,
    int? year,
  }) async {
    try {
      if (reset) {
        dashboard.clear();
        // Update filter parameters
        selectedCompanyId.value = companyId ?? "";
        selectedDivisionId.value = divisionId ?? "";
        selectedTransportId.value = transportId ?? "";
        selectedMonth.value = month ?? "";
        selectedYear.value = year ?? 0;
      }

      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {
        "employee_id": AppUtility.userID,
        "company_id": selectedCompanyId.value,
        "division_id": selectedDivisionId.value,
        "transport_id": selectedTransportId.value,
        "month": selectedMonth.value,
        "year": selectedYear.value != 0 ? selectedYear.value.toString() : "",
      };

      List<GetDashboardResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getDashboardDataListApi,
                Networkutility.getDashboardData,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetDashboardResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final dash = response[0].data;

          dashboard.add(
            DashboardData(
              noOfDispatch: dash.noOfDispatch,
              noOfPendingOverdue: dash.noOfPendingOverdue,
              noOfCompleted: dash.noOfCompleted,
              sumOfFreightAmountOne: dash.sumOfFreightAmountOne,
              sumOfFreightAmountTwo: dash.sumOfFreightAmountTwo,
              noOfInvoice: dash.noOfInvoice,
              claim: dash.claim,
              unclaim: dash.unclaim,
              delayInInvoicing: dash.delayInInvoicing,
              delayInDispatch: dash.delayInDispatch,
              delayInDelivery: dash.delayInDelivery,
            ),
          );
        } else {
          errorMessage.value = 'No data found';
          log('API returned status false: No data found');
        }
      } else {
        errorMessage.value = 'No response from server';
        log('No response from server');
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      log('NoInternetException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      log('TimeoutException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      log('ParseException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
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

  Future<void> refreshInwardList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      dashboard.clear();
      errorMessage.value = '';

      if (showLoading) {
        isLoading.value = true;
      }

      await fetchInwardList(
        context: context,
        reset: true,
        forceFetch: true,
        companyId: selectedCompanyId.value,
        divisionId: selectedDivisionId.value,
        transportId: selectedTransportId.value,
        month: selectedMonth.value,
        year: selectedYear.value,
      );

      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Dashboard refreshed successfully',
        //   backgroundColor: AppColors.success ?? Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh dashboard: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<void> deleteInward({
    BuildContext? context,
    required String? id,
  }) async {
    try {
      final jsonBody = {"employee_id": AppUtility.userID, "inward_id": id};

      isLoading.value = true;
      errorMessage.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.deleteInwardApi,
        Networkutility.deleteInward,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetDeleteInwardResponse> response = List.from(list);
        if (response[0].status == "true") {
          Get.snackbar(
            'Success',
            'Deleted successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          await fetchInwardList(context: context!, reset: true);
          Get.offNamed(AppRoutes.inwardlist);
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
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
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
}
