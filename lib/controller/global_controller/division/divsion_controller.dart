import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/global_model/company/get_company_response.dart';
import 'package:trailo/model/global_model/divison/get_division_response.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';

class DivsionController extends GetxController {
  RxList<DivisionData> divisionList = <DivisionData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedDivisionVal = RxString(""); // Initialize as null

  static DivsionController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Defer fetching until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        //fetchDivison(context: Get.context!); // Commented out as per original
      }
    });
  }

  Future<void> fetchDivison({
    required BuildContext context,
    bool forceFetch = false,
    required String? comapnyID,
  }) async {
    if (!forceFetch && divisionList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      // Clear previous divisions and reset selected value
      divisionList.clear();
      selectedDivisionVal?.value = ""; // Reset selected division
      final jsonBody = {
        "company_id": comapnyID,
      };

      List<GetDivisonResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getDivisionsApi,
                Networkutility.getDivisions,
                jsonEncode(jsonBody),
                context,
              ) as List<GetDivisonResponse>?;

      log(
        'Fetch Divisons Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          divisionList.value = response[0].data;
          log(
            'Divison List Loaded: ${divisionList.map((s) => "${s.divisionId}: ${s.divisionName}").toList()}',
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
      log('Fetch Divison Exception: $e, stack: $stackTrace');
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

  List<String> getDivisionNames() {
    return divisionList.map((s) => s.divisionName).toSet().toList();
  }

  String? getDivisionId(String cName) {
    return divisionList
            .firstWhereOrNull((state) => state.divisionName == cName)
            ?.divisionId ??
        '';
  }

  String? getDivisionNameById(String stateId) {
    return divisionList
        .firstWhereOrNull((state) => state.divisionId == stateId)
        ?.divisionName;
  }
}