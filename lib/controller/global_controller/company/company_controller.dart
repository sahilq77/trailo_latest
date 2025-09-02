import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/global_model/company/get_company_response.dart';
import 'package:trailo/utility/app_utility.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';

class CompanyController extends GetxController {
  RxList<CompanyData> companyList = <CompanyData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedCompanyVal;

  static CompanyController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Defer fetching until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchCompany(context: Get.context!);
      }
    });
  }

  Future<void> fetchCompany({
    required BuildContext context,
    bool forceFetch = false,
  }) async {
    log("Company api call");
    if (!forceFetch && companyList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final jsonBody = {"employee_id": AppUtility.userID.toString()};

      List<GetCompanyResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getCompanyApi,
                AppUtility.userType == "2"
                    ? Networkutility.getCompanySales
                    : Networkutility.getCompany,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetCompanyResponse>?;

      log(
        'Fetch Companies Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          companyList.value = response[0].data;
          log(
            'Company List Loaded: ${companyList.map((s) => "${s.companyId}: ${s.companyName}").toList()}',
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
      log('Fetch Companies Exception: $e, stack: $stackTrace');
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

  List<String> getCompanyNames() {
    return companyList.map((s) => s.companyName).toSet().toList();
  }

  String? getCompanyId(String cName) {
    return companyList
            .firstWhereOrNull((state) => state.companyName == cName)
            ?.companyId ??
        '';
  }

  String? getCompanyNameById(String stateId) {
    return companyList
        .firstWhereOrNull((state) => state.companyId == stateId)
        ?.companyName;
  }
}
