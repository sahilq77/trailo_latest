import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/checked_by_list/get_checked_by_list_response.dart';
import 'package:trailo/model/checked_by_list/get_packed_by_response.dart';
import 'package:trailo/model/completed_order/get_completed_order_list_response.dart';
import 'package:trailo/model/inward_list/get_inward_list_response.dart';
import 'package:trailo/model/outward_list/get_delete_outward_response.dart';
import 'package:trailo/model/outward_list/get_picked_response.dart';
import 'package:trailo/model/packed_by_list/packed_by_list_response.dart';
import 'package:trailo/model/picked_by_list/get_picked_by_list_response.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/view/inward/inward_list.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/inward_list/get_delete_inward_response.dart';
import '../../model/outward_list/get_outward_list_response.dart';
import '../../model/picked_by_list/get_transfer_to_checked_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class CompletedOrderListController extends GetxController {
  var completedOrderList = <CompletedOrderData>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoadingup = true.obs;
  var errorMessageUp = ''.obs;

  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMoreData = true.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxString totalInwards = "".obs;
  RxString receivedInwards = "".obs;
  RxString url = "".obs;

  // Store filter parameters
  RxString selectedCompanyId = "".obs;
  RxString startDate = "".obs;
  RxString endDate = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchPackedList(context: Get.context!);
  }

  Future<void> fetchPackedList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    String? companyId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Prevent concurrent calls
      if (reset) {
        offset.value = 0;
        completedOrderList.clear();
        hasMoreData.value = true;
        // Update filter parameters
        selectedCompanyId.value = companyId ?? "";
        this.startDate.value = startDate ?? "";
      }
      if (!hasMoreData.value && !reset) {
        log('No more data to fetch');
        return;
      }

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "employee_id": AppUtility.userID,
        "user_type": AppUtility.userType.toString(),
        "outward_id": "",
        "company_id": selectedCompanyId.value,
        "division_id": "",
        "receipt_date": startDate?.isNotEmpty == true ? startDate : "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      log('Fetching data with offset: ${offset.value}, limit: $limit');

      List<GetCompletedOrderListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.completedOrderListApi,
                Networkutility.completedOrderList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetCompletedOrderListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final outwards = response[0].data;
          url.value = response[0].documentPath ?? '';
          if (outwards!.isEmpty || outwards.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${outwards.length}');
          }

          // Check for duplicates before adding
          final existingIds = completedOrderList.map((item) => item.id).toSet();
          for (var outward in outwards) {
            if (!existingIds.contains(outward.id)) {
              completedOrderList.add(
                CompletedOrderData(
                  salesEmployeeName: outward.salesEmployeeName,
                  name: outward.name,
                  id: outward.id,
                  companyId: outward.companyId,
                  divisionId: outward.divisionId,
                  processType: outward.processType,
                  statusId: outward.statusId,
                  customerId: outward.customerId,
                  salesTeamEmployeeId: outward.salesTeamEmployeeId,
                  outwordDate: outward.outwordDate,
                  receiptDate: outward.receiptDate,
                  orderDate: outward.orderDate,
                  invoiceDateProcess: outward.invoiceDateProcess,
                  invoiceNumberProcess: outward.invoiceNumberProcess,
                  orderCopy: outward.orderCopy,
                  invoiceCopyNew: outward.invoiceCopyNew,
                  verificationStatus: outward.verificationStatus,
                  weight: outward.weight,
                  numOfCases: outward.numOfCases,
                  reason: outward.reason,
                  addedBy: outward.addedBy,
                  generatedBy: outward.generatedBy,
                  isDeleted: outward.isDeleted,
                  status: outward.status,
                  createdOn: outward.createdOn,
                  updatedOn: outward.updatedOn,
                  companyName: outward.companyName,
                  divisionName: outward.divisionName,
                  customerName: outward.customerName,
                  salesTeamEmployeeName: outward.salesTeamEmployeeName,
                  statusName: outward.statusName,
                  employeeName: outward.employeeName,
                  orderStatus: outward.orderStatus,
                  transportId: outward.transportId,
                  transportName: outward.transportName,
                  LrNumber: outward.LrNumber,
                  LrDate: outward.LrDate,
                ),
              );
              existingIds.add(outward.id);
            } else {
              log('Duplicate item skipped: ${outward.id}');
            }
          }

          offset.value += limit;
          log(
            'Offset updated to: ${offset.value}, Total items: ${completedOrderList.length}',
          );
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No outwards found';
          log('API returned status false: No outwards found');
        }
      } else {
        hasMoreData.value = false;
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
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreResults({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value && !isLoading.value) {
      log('Loading more results with offset: ${offset.value}');
      await fetchPackedList(
        context: context,
        isPagination: true,
        companyId: selectedCompanyId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );
    }
  }

  Future<void> refreshOutwardList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      // Reset state
      completedOrderList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      if (showLoading) {
        isLoading.value = true;
      }

      await fetchPackedList(
        context: context,
        reset: true,
        forceFetch: true,
        companyId: selectedCompanyId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Inwards refreshed successfully',
        //   backgroundColor: AppColors.success ?? Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh outwards: $e';
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
      final jsonBody = {"employee_id": AppUtility.userID, "outward_id": id};

      isLoadingup.value = true;
      errorMessageUp.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.deleteOutwardApi,
        Networkutility.deleteOutward,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetDeleteOutwardResponse> response = List.from(list);
        if (response[0].status == "true") {
          Get.snackbar(
            'Success',
            'Deleted successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          await fetchPackedList(context: context!, reset: true);
          Get.offNamed(AppRoutes.pickedbyoutward);
        } else {
          errorMessageUp.value = response[0].message;
          Get.snackbar(
            'Error',
            response[0].message,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessageUp.value = 'No response from server';
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      errorMessageUp.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessageUp.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessageUp.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessageUp.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessageUp.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoadingup.value = false;
      if (errorMessageUp.value.isNotEmpty) {
        Get.back();
      }
    }
  }

  Future<void> setChecked({
    BuildContext? context,
    required String? id,
    String? invNo,
    String? reason,
  }) async {
    try {
      final jsonBody = {
        "employee_id": AppUtility.userID,
        "outward_id": id,
        "invoice_number": invNo ?? "",
        "reason": reason ?? "",
      };

      isLoadingup.value = true;
      errorMessageUp.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.transferCheckedApi,
        Networkutility.transferChecked,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetTransferToCheckedResponse> response = List.from(list);

        if (response[0].status == "true") {
          Get.snackbar(
            'Success',
            'Checked successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          await refreshOutwardList(context: context!);
          Get.offNamed(AppRoutes.pickedbyoutward);
        } else {
          errorMessageUp.value = response[0].message;
          Get.snackbar(
            'Error',
            response[0].message,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        errorMessageUp.value = 'No response from server';
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      errorMessageUp.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessageUp.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessageUp.value = '${e.message} (Code: ${e.statusCode})';
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessageUp.value = e.message;
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessageUp.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoadingup.value = false;
      if (errorMessageUp.value.isNotEmpty) {
        Get.back();
      }
    }
  }
}
