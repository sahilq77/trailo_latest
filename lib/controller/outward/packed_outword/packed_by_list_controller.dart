import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/checked_by_list/get_checked_by_list_response.dart';
import 'package:trailo/model/checked_by_list/get_packed_by_response.dart';
import 'package:trailo/model/inward_list/get_inward_list_response.dart';
import 'package:trailo/model/outward_list/get_delete_outward_response.dart';
import 'package:trailo/model/outward_list/get_picked_response.dart';
import 'package:trailo/model/packed_by_list/packed_by_list_response.dart';
import 'package:trailo/model/picked_by_list/get_picked_by_list_response.dart';
import 'package:trailo/model/picked_by_list/get_transfer_to_checked_response.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/view/inward/inward_list.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../model/inward_list/get_delete_inward_response.dart';
import '../../../model/outward_list/get_outward_list_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utility.dart';
import '../../../utility/custom_flushbar.dart';

class PackedByListController extends GetxController {
  var packedByList = <PackedByListData>[].obs;
  var packedByDetail = <PackedByListData>[].obs;
  var errorMessaged = ''.obs;
  var errorMessage = ''.obs;
  RxBool isLoadingup = true.obs;
  RxBool isLoadingd = true.obs;
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
      if (reset) {
        offset.value = 0;
        packedByList.clear();
        hasMoreData.value = true;
        selectedCompanyId.value = companyId ?? "";
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
        "user_type": AppUtility.userType,
        "outward_id": "",
        "company_id": selectedCompanyId.value,
        "division_id": "",
        "receipt_date": startDate?.isNotEmpty == true ? startDate : "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      log('Fetching packed list with body: $jsonBody');

      List<GetPackedByListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.packedByListApi,
                Networkutility.packedByList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetPackedByListResponse>?;

      log('Packed list API response: $response');

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final outwards = response[0].data;
          url.value = response[0].documentPath ?? '';
          if (outwards!.isEmpty || outwards.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${outwards.length}');
          }

          final existingIds = packedByList.map((item) => item.id).toSet();
          for (var outward in outwards) {
            if (!existingIds.contains(outward.id)) {
              packedByList.add(
                PackedByListData(
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
            'Offset updated to: ${offset.value}, Total items: ${packedByList.length}',
          );
        } else {
          hasMoreData.value = false;
          errorMessage.value = response[0].message ?? 'No outwards found';
          log('API returned status false: ${errorMessage.value}');
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        log('No response from server');
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      log('NoInternetException: ${e.message}');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      log('TimeoutException: ${e.message}');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        context,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      log('ParseException: ${e.message}');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        'Unexpected error: $e',
        context,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchPackedByDetails({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
    required String id,
  }) async {
    try {
      if (reset) {
        packedByDetail.clear();
      }
      isLoadingd.value = true;
      errorMessaged.value = '';

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

      log('Fetching packed details with body: $jsonBody');

      List<GetPackedByListResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.packedByListApi,
                Networkutility.packedByList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetPackedByListResponse>?;

      log('Packed details API response: $response');

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final outwards = response[0].data;
          url.value = response[0].documentPath ?? '';
          if (outwards!.isEmpty) {
            log('No details received for outward_id: $id');
            errorMessaged.value = 'No details found for this outward';
          } else {
            final existingIds = packedByDetail.map((item) => item.id).toSet();
            for (var outward in outwards) {
              if (!existingIds.contains(outward.id)) {
                packedByDetail.add(
                  PackedByListData(
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
                log('Duplicate detail item skipped: ${outward.id}');
              }
            }
            log('PackedByDetail updated: ${packedByDetail.length} items');
          }
        } else {
          errorMessaged.value = response[0].message ?? 'No details found';
          log('API returned status false: ${errorMessaged.value}');
        }
      } else {
        errorMessaged.value = 'No response from server';
        log('No response from server for details');
      }
    } on NoInternetException catch (e) {
      errorMessaged.value = e.message;
      log('NoInternetException: ${e.message}');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } on TimeoutException catch (e) {
      errorMessaged.value = e.message;
      log('TimeoutException: ${e.message}');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } on HttpException catch (e) {
      errorMessaged.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        context,
      );
    } on ParseException catch (e) {
      errorMessaged.value = e.message;
      log('ParseException: ${e.message}');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } catch (e) {
      errorMessaged.value = 'Unexpected error: $e';
      log('Unexpected error in fetchPackedByDetails: $e');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        'Unexpected error: $e',
        context,
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
    packedByDetail.clear();
    errorMessaged.value = '';

    if (showLoading) {
      isLoadingd.value = true;
    }
    await fetchPackedByDetails(context: context!, id: id!, reset: true);
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
      packedByList.clear();
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
        CustomFlushbar.flushBarSuccessMessage(
          'Success',
          'Outwards refreshed successfully',
          context,
        );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh outwards: $e';
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        errorMessage.value,
        context,
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
          CustomFlushbar.flushBarSuccessMessage(
            'Success',
            'Deleted successfully',
            context!,
          );
          await fetchPackedList(context: context!, reset: true);
          Get.offNamed(AppRoutes.pickedbyoutward);
        } else {
          errorMessageUp.value = response[0].message;
          CustomFlushbar.flushBarErrorMessage(
            'Error',
            response[0].message,
            context!,
          );
        }
      } else {
        errorMessageUp.value = 'No response from server';
        CustomFlushbar.flushBarErrorMessage(
          'Error',
          'No response from server',
          context!,
        );
      }
    } on NoInternetException catch (e) {
      errorMessageUp.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } on TimeoutException catch (e) {
      errorMessageUp.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } on HttpException catch (e) {
      errorMessageUp.value = '${e.message} (Code: ${e.statusCode})';
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        context!,
      );
    } on ParseException catch (e) {
      errorMessageUp.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } catch (e) {
      errorMessageUp.value = 'Unexpected error: $e';
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        'Unexpected error: $e',
        context!,
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
    required String? invNo,
    required String? reason,
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
          CustomFlushbar.flushBarSuccessMessage(
            'Success',
            'Transfer to Checked Successfully',
            context!,
          );
          await fetchPackedList(context: context!, reset: true);
          await refreshOutwardList(context: context!, showLoading: false);
          Get.offNamed(AppRoutes.pickedbyoutward);
        } else {
          errorMessageUp.value = response[0].message;
          CustomFlushbar.flushBarErrorMessage(
            'Error',
            response[0].message,
            context!,
          );
        }
      } else {
        errorMessageUp.value = 'No response from server';
        CustomFlushbar.flushBarErrorMessage(
          'Error',
          'No response from server',
          context!,
        );
      }
    } on NoInternetException catch (e) {
      errorMessageUp.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } on TimeoutException catch (e) {
      errorMessageUp.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } on HttpException catch (e) {
      errorMessageUp.value = '${e.message} (Code: ${e.statusCode})';
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        context!,
      );
    } on ParseException catch (e) {
      errorMessageUp.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } catch (e) {
      errorMessageUp.value = 'Unexpected error: $e';
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        'Unexpected error: $e',
        context!,
      );
    } finally {
      isLoadingup.value = false;
      if (errorMessageUp.value.isNotEmpty) {
        Get.back();
      }
    }
  }
}