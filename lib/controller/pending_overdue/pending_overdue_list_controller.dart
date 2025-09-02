import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/pending_deliveries/get_peding_overdue_list_response.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class PendingOverdueListController extends GetxController {
  var pendingOverdueList = <PendingOverdueData>[].obs;
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
    fetchOverdue(context: Get.context!);
  }

  Future<void> fetchOverdue({
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
        pendingOverdueList.clear();
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
        "outward_id": "",
        "company_id": selectedCompanyId.value,
        "division_id": "",
        "receipt_date": startDate?.isNotEmpty == true ? startDate : "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      log('Fetching data with offset: ${offset.value}, limit: $limit');

      List<GetPendingOverdueListReponse>? response =
          (await Networkcall().postMethod(
                Networkutility.pendingOverdueListApi,
                Networkutility.pendingOverdueList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetPendingOverdueListReponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final outwards = response[0].data;
          url.value = response[0].documentPath ?? '';
          if (outwards!.isEmpty || outwards.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${outwards.length}');
          }

          // Check for duplicates before adding
          final existingIds = pendingOverdueList.map((item) => item.id).toSet();
          for (var outward in outwards) {
            if (!existingIds.contains(outward.id)) {
              pendingOverdueList.add(
                PendingOverdueData(
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
                ),
              );
              existingIds.add(outward.id);
            } else {
              log('Duplicate item skipped: ${outward.id}');
            }
          }

          offset.value += limit;
          log(
            'Offset updated to: ${offset.value}, Total items: ${pendingOverdueList.length}',
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
      await fetchOverdue(
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
      pendingOverdueList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      if (showLoading) {
        isLoading.value = true;
      }

      await fetchOverdue(
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
}
