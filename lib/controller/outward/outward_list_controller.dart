import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/controller/outward/checked_list_controller.dart';
import 'package:trailo/model/inward_list/get_inward_list_response.dart';
import 'package:trailo/model/outward_list/get_delete_outward_response.dart';
import 'package:trailo/model/outward_list/get_picked_response.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/view/inward/inward_list.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/inward_list/get_delete_inward_response.dart';
import '../../model/outward_list/get_outward_list_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';

class OutwardListController extends GetxController {
  var outwardList = <OutwardListData>[].obs;
  var outwardDetail = <OutwardListData>[].obs;
  var errorMessage = ''.obs;
  var errorMessageDetail = ''.obs;
  RxBool isLoadingup = true.obs;
  RxBool isLoadingDetail = true.obs;
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
  final checkedController = Get.put(CheckedListController());

  @override
  void onInit() {
    super.onInit();
    fetchOutwardList(context: Get.context!);
  }

  Future<void> fetchOutwardDetails({
    required BuildContext context,
    bool reset = false,
    required String id,
  }) async {
    try {
      if (reset) {
        outwardDetail.clear();
      }
      isLoadingDetail.value = true;
      errorMessageDetail.value = '';

      final jsonBody = {
        "employee_id": AppUtility.userID,
        "user_type": AppUtility.userType,
        "outward_id": id,
        "company_id": "",
        "division_id": "",
        "receipt_date": "",
        "limit": "",
        "offset": "",
      };

      log('Fetching outward details with body: $jsonBody');

      List<GetOutwardListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.outwardListApi,
                Networkutility.outwardList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetOutwardListResponse>?;

      log('Outward details API response: $response');

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final outwards = response[0].data;
          url.value = response[0].documentPath ?? '';
          if (outwards.isEmpty) {
            log('No details received for outward_id: $id');
            errorMessageDetail.value = 'No details found for this outward';
          } else {
            final existingIds = outwardDetail.map((item) => item.id).toSet();
            for (var outward in outwards) {
              if (!existingIds.contains(outward.id)) {
                outwardDetail.add(
                  OutwardListData(
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
                    salesEmployeeName: outward.salesEmployeeName,
                  ),
                );
                existingIds.add(outward.id);
              } else {
                log('Duplicate detail item skipped: ${outward.id}');
              }
            }
            log('OutwardDetail updated: ${outwardDetail.length} items');
          }
        } else {
          errorMessageDetail.value = response[0].message ?? 'No details found';
          log('API returned status false: ${errorMessageDetail.value}');
        }
      } else {
        errorMessageDetail.value = 'No response from server';
        log('No response from server for details');
      }
    } on NoInternetException catch (e) {
      errorMessageDetail.value = e.message;
      log('NoInternetException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      errorMessageDetail.value = e.message;
      log('TimeoutException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      errorMessageDetail.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      errorMessageDetail.value = e.message;
      log('ParseException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessageDetail.value = 'Unexpected error: $e';
      log('Unexpected error in fetchOutwardDetails: $e');
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoadingDetail.value = false;
    }
  }

  Future<void> refreshOutwardDetails({
    required BuildContext context,
    required String id,
    bool showLoading = true,
  }) async {
    outwardDetail.clear();
    errorMessageDetail.value = '';

    if (showLoading) {
      isLoadingDetail.value = true;
    }
    await fetchOutwardDetails(context: context, id: id, reset: true);
  }

  Future<void> fetchOutwardList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    String? companyId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        outwardList.clear();
        hasMoreData.value = true;
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

      List<GetOutwardListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.outwardListApi,
                Networkutility.outwardList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetOutwardListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final outwards = response[0].data;
          url.value = response[0].documentPath;
          if (outwards.isEmpty || outwards.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${outwards.length}');
          }
          for (var outward in outwards) {
            outwardList.add(
              OutwardListData(
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
                salesEmployeeName: outward.salesEmployeeName,
              ),
            );
          }
          offset.value += limit;
          log('Offset updated to: ${offset.value}');
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
      await fetchOutwardList(
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
      outwardList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      if (showLoading) {
        isLoading.value = true;
      }

      await fetchOutwardList(
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
          await fetchOutwardList(context: context!, reset: true);
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

  Future<void> setPicked({
    BuildContext? context,
    required String? id,
    String? reason,
  }) async {
    try {
      final jsonBody = {
        "employee_id": AppUtility.userID,
        "outward_id": id,
        "reason": reason ?? "",
      };

      isLoadingup.value = true;
      errorMessageUp.value = '';

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.transforPickedApi,
        Networkutility.transforPicked,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetPickedResponse> response = List.from(list);

        if (response[0].status == "true") {
          if (reason == null) {
            Get.snackbar(
              'Success',
              'Transfer to Picked Successfully',
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );
            await fetchOutwardList(context: context!, reset: true);
            await refreshOutwardList(context: context!, showLoading: false);
            Get.offNamed(AppRoutes.outwardList);
          } else {
            Get.snackbar(
              'Success',
              'Transfer to Picked Successfully',
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );
            await checkedController.fetchCheckedList(
              context: context!,
              reset: true,
            );
            await checkedController.refreshOutwardList(
              context: context!,
              showLoading: false,
            );
            Get.offNamed(AppRoutes.checkedbyoutward);
          }
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
