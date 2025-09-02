import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/global_model/company/get_company_response.dart';
import 'package:trailo/model/global_model/divison/get_division_response.dart';
import 'package:trailo/model/global_model/customers/get_customers_response.dart';
import 'package:trailo/utility/app_utility.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';

class CustomerController extends GetxController {
  RxList<CustomersData> customersList = <CustomersData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString selectedCustomerVal = ''.obs; // Properly initialized as RxString

  static CustomerController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Defer fetching until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchCustomers(context: Get.context!);
      }
    });
  }

  Future<void> fetchCustomers({
    required BuildContext context,
    bool forceFetch = false,
  }) async {
    print("Fetching customers, forceFetch: $forceFetch");
    if (!forceFetch && customersList.isNotEmpty) {
      print("Customers already loaded: ${customersList.length}");
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final jsonBody = {"Employee_id": AppUtility.userID};

      List<GetCustomersResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getCustomersApi,
                Networkutility.getCustomers,
                jsonEncode(jsonBody),
                context,
              ) as List<GetCustomersResponse>?;

      log(
        'Fetch Customers Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          customersList.value = response[0].data;
          log(
            'Customer List Loaded: ${customersList.map((s) => "${s.customerId}: ${s.customerName}").toList()}',
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
      log('Fetch Customer Exception: $e, stack: $stackTrace');
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

  List<String> getCustomerNames() {
    log(
      "Customer name list: ${customersList.map((s) => s.customerName).toSet().toList()}",
    );
    return customersList.map((s) => s.customerName).toSet().toList();
  }

  String? getCustomerId(String cName) {
    log(
      "Customer ID for $cName: ${customersList.firstWhereOrNull((state) => state.customerName == cName)?.customerId}",
    );
    return customersList
            .firstWhereOrNull((state) => state.customerName == cName)
            ?.customerId ??
        '';
  }

  String? getCustomerNameById(String stateId) {
    final customerName = customersList
        .firstWhereOrNull((state) => state.customerId == stateId)
        ?.customerName;
    log("Customer name for ID $stateId: $customerName");
    return customerName;
  }
}