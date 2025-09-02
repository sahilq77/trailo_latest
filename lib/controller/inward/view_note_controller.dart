import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/inward_list/get_view_notes_response.dart';
import 'package:trailo/utility/app_colors.dart';
import 'package:trailo/utility/app_utility.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';

class ViewNoteController extends GetxController {
  var noteList = <CreditNote>[].obs;
  var errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMoreData = true.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxString url = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchNoteDetails(context: Get.context!, inwardId: "2727");
  }

  Future<void> fetchNoteDetails({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    required String? inwardId,
  }) async {
    try {
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
        "inward_id": inwardId.toString(),
        "limit": limit.toString(),
        "offset": offset.value.toString(),
      };

      List<GetViewNotesResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getNoteDetailsApi,
                Networkutility.getNoteDetails,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetViewNotesResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final notes = response[0].data?.creditNotes ?? [];
          url.value = response[0].documentPath ?? '';
          if (reset) {
            noteList.clear();
            offset.value = 0;
          }
          if (notes.isEmpty || notes.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${notes.length}');
          }
          noteList.addAll(notes); // Add to existing list instead of replacing
          offset.value += limit;
          log('Offset updated to: ${offset.value}');
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No notes found';
          log('API returned status false: No notes found');
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

  Future<void> refreshNoteList({
    required BuildContext context,
    required String? inwardId,
    bool showLoading = true,
  }) async {
    try {
      noteList.clear();
      errorMessage.value = '';
      offset.value = 0;
      hasMoreData.value = true;

      if (showLoading) {
        isLoading.value = true;
      }

      await fetchNoteDetails(context: context, reset: true, inwardId: inwardId);

      if (errorMessage.value.isEmpty) {
        // Get.snackbar(
        //   'Success',
        //   'Notes refreshed successfully',
        //   backgroundColor: AppColors.success ?? Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      }
    } catch (e) {
      errorMessage.value = 'Failed to refresh notes: $e';
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
