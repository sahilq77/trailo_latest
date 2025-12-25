import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/inward_list/get_inward_list_response.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/view/inward/inward_list.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/inward_list/get_delete_inward_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class InwardListController extends GetxController {
  var inwardList = <InwardListData>[].obs;
  var inwardDetail = <InwardListData>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoadingup = true.obs;
  var errorMessageUp = ''.obs;
  var errorMessaged = ''.obs;

  RxBool isLoadingd = true.obs;
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
  RxString selectedDivisionId = "".obs;
  RxString startDate = "".obs;
  RxString endDate = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchInwardList(context: Get.context!);
  }

  Future<void> fetchInwardList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    String? companyId,
    String? divisionId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        inwardList.clear();
        hasMoreData.value = true;
        // Update filter parameters
        selectedCompanyId.value = companyId ?? "";
        selectedDivisionId.value = divisionId ?? "";
        this.startDate.value = startDate ?? "";
        this.endDate.value = endDate ?? "";
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
        "inward_id": "",
        "company_id": selectedCompanyId.value,
        "division_id": selectedDivisionId.value,
        "receipt_date": startDate?.isNotEmpty == true ? "${startDate}" : "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetInwardListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.inwardListApi,
                Networkutility.inwardList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetInwardListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final inwards = response[0].data;
          url.value = response[0].documentPath;
          if (inwards.isEmpty || inwards.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${inwards.length}');
          }
          for (var inward in inwards) {
            inwardList.add(
              InwardListData(
                id: inward.id,
                companyId: inward.companyId,
                divisionId: inward.divisionId,
                customerId: inward.customerId,
                vendorId: inward.vendorId,
                statusId: inward.statusId,
                transportId: inward.transportId,
                receiptDate: inward.receiptDate,
                inwardNumber: inward.inwardNumber,
                entityType: inward.entityType,
                debitNoteNumber: inward.debitNoteNumber,
                debitNoteDate: inward.debitNoteDate,
                vendorInvoiceNumber: inward.vendorInvoiceNumber,
                vendorInvoiceDate: inward.vendorInvoiceDate,
                lrNumber: inward.lrNumber,
                lrDate: inward.lrDate,
                freightAmount: inward.freightAmount,
                claim: inward.claim,
                lrCopy: inward.lrCopy,
                debitNoteCopy: inward.debitNoteCopy,
                invoiceCopy: inward.invoiceCopy,
                isVerified: inward.isVerified,
                addedBy: inward.addedBy,
                isDeleted: inward.isDeleted,
                status: inward.status,
                createdOn: inward.createdOn,
                updatedOn: inward.updatedOn,
                companyName: inward.companyName,
                divisionName: inward.divisionName,
                customerName: inward.customerName,
                vendorName: inward.vendorName,
                statusName: inward.statusName,
                transportName: inward.transportName,
              ),
            );
          }
          offset.value += limit;
          log('Offset updated to: ${offset.value}');
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No inwards found';
          log('API returned status false: No inwards found');
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

  Future<void> fetchInwardDetail({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    required String id,
  }) async {
    try {
      if (reset) {
        inwardDetail.clear();
      }
      isLoadingd.value = true;

      errorMessaged.value = '';

      final jsonBody = {
        "employee_id": AppUtility.userID,
        "user_type": AppUtility.userType.toString(),
        "inward_id": id,
        "company_id": "",
        "division_id": "",
        "receipt_date": "",
        "limit": "",
        "offset": "",
      };

      List<GetInwardListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.inwardListApi,
                Networkutility.inwardList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetInwardListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final inwards = response[0].data;
          url.value = response[0].documentPath;
          if (inwards.isEmpty || inwards.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${inwards.length}');
          }
          for (var inward in inwards) {
            inwardDetail.add(
              InwardListData(
                id: inward.id,
                companyId: inward.companyId,
                divisionId: inward.divisionId,
                customerId: inward.customerId,
                vendorId: inward.vendorId,
                statusId: inward.statusId,
                transportId: inward.transportId,
                receiptDate: inward.receiptDate,
                inwardNumber: inward.inwardNumber,
                entityType: inward.entityType,
                debitNoteNumber: inward.debitNoteNumber,
                debitNoteDate: inward.debitNoteDate,
                vendorInvoiceNumber: inward.vendorInvoiceNumber,
                vendorInvoiceDate: inward.vendorInvoiceDate,
                lrNumber: inward.lrNumber,
                lrDate: inward.lrDate,
                freightAmount: inward.freightAmount,
                claim: inward.claim,
                lrCopy: inward.lrCopy,
                debitNoteCopy: inward.debitNoteCopy,
                invoiceCopy: inward.invoiceCopy,
                isVerified: inward.isVerified,
                addedBy: inward.addedBy,
                isDeleted: inward.isDeleted,
                status: inward.status,
                createdOn: inward.createdOn,
                updatedOn: inward.updatedOn,
                companyName: inward.companyName,
                divisionName: inward.divisionName,
                customerName: inward.customerName,
                vendorName: inward.vendorName,
                statusName: inward.statusName,
                transportName: inward.transportName,
              ),
            );
          }
        } else {
          errorMessaged.value = 'No inwards found';
          log('API returned status false: No inwards found');
        }
      } else {
        errorMessaged.value = 'No response from server';
        log('No response from server');
      }
    } on NoInternetException catch (e) {
      errorMessaged.value = e.message;
      log('NoInternetException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessaged.value = e.message;
      log('TimeoutException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessaged.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessaged.value = e.message;
      log('ParseException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessaged.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoadingd.value = false;
    }
  }

  Future<void> refreshDetails({
    BuildContext? context,
    String? id,
    bool showLoading = true,
  }) async {
    inwardDetail.clear();
    errorMessaged.value = '';

    if (showLoading) {
      isLoadingd.value = true;
    }
    await fetchInwardDetail(context: context!, id: id!, reset: true);
  }

  Future<void> loadMoreResults({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value && !isLoading.value) {
      log('Loading more results with offset: ${offset.value}');
      await fetchInwardList(
        context: context,
        isPagination: true,
        companyId: selectedCompanyId.value,
        divisionId: selectedDivisionId.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );
    }
  }

  Future<void> refreshInwardList({
    required BuildContext context,
    bool showLoading = true,
  }) async {
    try {
      inwardList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      if (showLoading) {
        isLoading.value = true;
      }

      await fetchInwardList(
        context: context,
        reset: true,
        forceFetch: true,
        companyId: selectedCompanyId.value,
        divisionId: selectedDivisionId.value,
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
      errorMessage.value = 'Failed to refresh inwards: $e';
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

      isLoadingup.value = true;
      errorMessageUp.value = '';

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
          Navigator.pop(context);
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
