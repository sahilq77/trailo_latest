import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/global_model/company/get_company_response.dart';
import 'package:trailo/model/global_model/divison/get_division_response.dart';
import 'package:trailo/model/global_model/employee/get_employee_response.dart';
import 'package:trailo/model/global_model/status/get_status_response.dart';
import 'package:trailo/model/global_model/store_employee/get_store_employee.dart';
import 'package:trailo/model/global_model/transport/get_all_transport_response.dart';
import 'package:trailo/utility/app_utility.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../model/global_model/customers/get_customers_response.dart';
import '../../../utility/app_colors.dart';

class StoreEmployeeController extends GetxController {
  RxList<StoreEmployeeData> storeEmployee = <StoreEmployeeData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedStoreEmployeeVal;

  static StoreEmployeeController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Defer fetching until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchStoreEmployee(context: Get.context!);
      }
    });
  }

  Future<void> fetchStoreEmployee({
    required BuildContext context,
    bool forceFetch = false,
  }) async {
    print("Called");
    if (!forceFetch && storeEmployee.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final jsonBody = {"Employee_id": AppUtility.userID};

      List<GetStoreEmployeeResponse>? response =
          await Networkcall().postMethod(
                Networkutility.storeEmployeeApi,
                Networkutility.storeEmployee,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetStoreEmployeeResponse>?;

      log(
        'Fetch Employees Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          storeEmployee.value = response[0].data;
          log(
            'Employee List Loaded: ${storeEmployee.map((s) => "${s.employeeId}: ${s.employeeName}").toList()}',
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

  List<String> getStoreEmployeeNames() {
    return storeEmployee.map((s) => s.employeeName).toSet().toList();
  }

  String? getStoreEmployeeId(String cName) {
    return storeEmployee
            .firstWhereOrNull((state) => state.employeeName == cName)
            ?.employeeId ??
        '';
  }

  String? getStoreEmployeeNameById(String stateId) {
    return storeEmployee
        .firstWhereOrNull((state) => state.employeeId == stateId)
        ?.employeeId;
  }
}
