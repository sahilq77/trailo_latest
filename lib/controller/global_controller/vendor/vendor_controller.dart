import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/global_model/company/get_company_response.dart';
import 'package:trailo/model/global_model/divison/get_division_response.dart';
import 'package:trailo/model/global_model/transport/get_all_transport_response.dart';
import 'package:trailo/utility/app_utility.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../model/global_model/customers/get_customers_response.dart';
import '../../../model/vendor/get_vender_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/custom_flushbar.dart';

class VendorController extends GetxController {
  RxList<VendorData> vendorsList = <VendorData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString? selectedVendorVal;

  static VendorController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    selectedVendorVal = ''.obs; // Initialize selectedVendorVal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchVendors(context: Get.context!);
      }
    });
  }

  Future<void> fetchVendors({
    required BuildContext context,
    bool forceFetch = false,
  }) async {
    if (!forceFetch && vendorsList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final jsonBody = {"Employee_id": AppUtility.userID};

      List<GetVendorsResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getVendorsApi,
                Networkutility.getVendors,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetVendorsResponse>?;

      log(
        'Fetch Vendors Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          vendorsList.value = response[0].data;
          log(
            'Vendor List Loaded: ${vendorsList.map((s) => "${s.vendorId}: ${s.vendorName}").toList()}',
          );
        } else {
          errorMessage.value = response[0].message;
          CustomFlushbar.flushBarErrorMessage(
            'Error',
            response[0].message,
            context,
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        CustomFlushbar.flushBarErrorMessage(
          'Error',
          'No response from server',
          context,
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        context,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch Vendor Exception: $e, stack: $stackTrace');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        'Unexpected error: $e',
        context,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<String> getVendorNames() {
    log("Vendor list names: ${vendorsList.map((s) => s.vendorName).toList()}");
    return vendorsList.map((s) => s.vendorName).toList();
  }

  String? getVendorId(String cName) {
    log("Looking for vendor ID for name: $cName");
    final vendorId = vendorsList
        .firstWhereOrNull((state) => state.vendorName == cName)
        ?.vendorId;
    log("Found vendor ID: $vendorId");
    return vendorId ?? '';
  }

  String? getVendorNameById(String stateId) {
    final vendorName = vendorsList
        .firstWhereOrNull((state) => state.vendorId == stateId)
        ?.vendorName;
    log("Found vendor name for ID $stateId: $vendorName");
    return vendorName;
  }
}