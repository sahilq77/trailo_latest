import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:trailo/core/urls.dart';
import 'package:trailo/utility/app_utility.dart';
import 'package:trailo/utility/app_colors.dart';
import 'package:trailo/utility/app_routes.dart';


import '../../../core/network/exceptions.dart';
import '../inward_list_controller.dart';

class AddInwardController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var lrCopyFile = Rxn<PlatformFile>();
  var invoiceCopyFile = Rxn<PlatformFile>();
  var debitNoteCopyFile = Rxn<PlatformFile>();
  final controller = Get.put(InwardListController());



  Future<void> pickFile(String field) async {
    try {
      log('Picking file for field: $field');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        log(
          'File picked: ${result.files.first.path}, name: ${result.files.first.name}',
        );
        switch (field) {
          case 'lr_copy':
            lrCopyFile.value = result.files.first;
            break;
          case 'invoice_copy':
            invoiceCopyFile.value = result.files.first;
            break;
          case 'debit_note_copy':
            debitNoteCopyFile.value = result.files.first;
            break;
        }
        update();
      } else {
        log('No file selected for field: $field');
      }
    } catch (e, stackTrace) {
      log('Error picking file for $field: $e', stackTrace: stackTrace);
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',

        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitInwardData({
    required Map<String, String> data,
    required BuildContext context,
    required String id,
  }) async {
    try {
      isLoading.value = true;
      log('Submitting inward data: $data');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.addInward),
      );

      // Add form fields
      data.forEach((key, value) {
        if (value.isNotEmpty && value != 'null') {
          log('Adding field $key: $value');
          request.fields[key] = value;
        }
      });

      // Add file uploads using file paths
      if (lrCopyFile.value != null && lrCopyFile.value!.path != null) {
        log('Adding lr_copy file: ${lrCopyFile.value!.path}');
        final file = File(lrCopyFile.value!.path!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'lr_copy',
              lrCopyFile.value!.path!,
              filename: lrCopyFile.value!.name,
            ),
          );
        } else {
          log('lr_copy file does not exist: ${lrCopyFile.value!.path}');
          throw Exception('lr_copy file not found');
        }
      } else {
        log('No lr_copy file selected or path is null');
      }

      if (invoiceCopyFile.value != null &&
          invoiceCopyFile.value!.path != null) {
        log('Adding invoice_copy file: ${invoiceCopyFile.value!.path}');
        final file = File(invoiceCopyFile.value!.path!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'invoice_copy',
              invoiceCopyFile.value!.path!,
              filename: invoiceCopyFile.value!.name,
            ),
          );
        } else {
          log(
            'invoice_copy file does not exist: ${invoiceCopyFile.value!.path}',
          );
          throw Exception('invoice_copy file not found');
        }
      } else {
        log('No invoice_copy file selected or path is null');
      }

      if (debitNoteCopyFile.value != null &&
          debitNoteCopyFile.value!.path != null) {
        log('Adding debit_note_copy file: ${debitNoteCopyFile.value!.path}');
        final file = File(debitNoteCopyFile.value!.path!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'debit_note_copy',
              debitNoteCopyFile.value!.path!,
              filename: debitNoteCopyFile.value!.name,
            ),
          );
        } else {
          log(
            'debit_note_copy file does not exist: ${debitNoteCopyFile.value!.path}',
          );
          throw Exception('debit_note_copy file not found');
        }
      } else {
        log('No debit_note_copy file selected or path is null');
      }

      // Log request details
      log('Request URL: ${request.url}');
      log('Request fields: ${request.fields}');
      log('Request files: ${request.files.map((f) => f.filename).toList()}');

      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      log('Response status: ${response.statusCode}');
      log('Response body: $responseData');

      isLoading.value = false;

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        log('Parsed response: $jsonResponse');
        if (jsonResponse['status'] == 'true') {
          if (id.isNotEmpty) {
            await controller.refreshDetails(context: context, id: id);
            Navigator.pop(context);
            Get.snackbar(
              'Success',
              'Inward Edited Successfully',
              backgroundColor: AppColors.success,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              'Success',
              'Inward Added Successfully',
              backgroundColor: AppColors.success,
              colorText: Colors.white,
            );
            Get.offNamed(AppRoutes.inwardlist);
          }
        } else {
          Get.snackbar(
            'Failed',
            'Failed to Add Data',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        Get.back();
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Unexpected errorColor: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? getFileName(String field) {
    switch (field) {
      case 'lr_copy':
        return lrCopyFile.value?.name;
      case 'invoice_copy':
        return invoiceCopyFile.value?.name;
      case 'debit_note_copy':
        return debitNoteCopyFile.value?.name;
      default:
        return null;
    }
  }
}
