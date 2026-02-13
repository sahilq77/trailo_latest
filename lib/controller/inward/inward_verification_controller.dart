import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:trailo/controller/inward/inward_list_controller.dart';
import 'package:trailo/core/urls.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/utility/app_utility.dart';
import 'package:trailo/utility/app_colors.dart';
import '../../../core/network/exceptions.dart';

class InwardVerificationController extends GetxController {
  final controller = Get.put(InwardListController());
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var creditNoteFiles = <PlatformFile>[].obs; // List of credit note files
  var grnFiles = <PlatformFile>[].obs; // List of GRN files
  var mrnCopyFile = Rxn<PlatformFile>();

  Future<void> pickFile(String field, {bool allowMultiple = true}) async {
    try {
      log('Picking file for field: $field, allowMultiple: $allowMultiple');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: allowMultiple,
      );

      if (result != null && result.files.isNotEmpty) {
        log('Files picked: ${result.files.map((f) => f.name).toList()}');
        switch (field) {
          case 'credit_note_copy':
            creditNoteFiles.clear();
            creditNoteFiles.addAll(result.files);
            log(
              'Added ${result.files.length} files to creditNoteFiles: ${creditNoteFiles.map((f) => f.name).toList()}',
            );
            break;
          case 'grn_copy':
            grnFiles.clear();
            grnFiles.addAll(result.files);
            log(
              'Added ${result.files.length} files to grnFiles: ${grnFiles.map((f) => f.name).toList()}',
            );
            break;
          case 'mrn_copy':
            mrnCopyFile.value = result.files.first;
            log('Assigned file to mrnCopyFile: ${mrnCopyFile.value?.name}');
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
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> submitInwardVerificationData({
    required Map<String, dynamic> data,
    required BuildContext context,
    required String id,
  }) async {
    try {
      isLoading.value = true;
      log('Submitting inward verification data: $data');

      // Validate entity_type
      final entityType = int.tryParse(data['entity_type']?.toString() ?? '0');
      if (entityType == 1 && creditNoteFiles.isEmpty) {
        log('Validation failed: No credit note files for customer');
        throw Exception(
          'Credit note copy is required for customer (entity_type: 1)',
        );
      } else if (entityType == 0 && grnFiles.isEmpty) {
        log('Validation failed: No GRN files for vendor');
        throw Exception('GRN copy is required for vendor (entity_type: 0)');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.addInwardVerification),
      );

      // Add form fields
      final fields = {
        'employee_id': data['employee_id']?.toString() ?? '',
        'inward_id': data['inward_id']?.toString() ?? '',
        'inward_number': data['inward_number']?.toString() ?? '',
        'status_id': data['status_id']?.toString() ?? '',
        'mrn_prepared_by': data['mrn_prepared_by']?.toString() ?? '',
        'mrn_checked_by': data['mrn_checked_by']?.toString() ?? '',
        'stocks_arranged_by': data['stocks_arranged_by']?.toString() ?? '',
        'remark': data['remark']?.toString() ?? '',
        'entity_type': data['entity_type']?.toString() ?? '',
        'debit_no': data['debit_no']?.toString() ?? '',
        'debit_date': data['debit_date']?.toString() ?? '',
        'credit_no': jsonEncode(data['credit_no'] ?? []),
        'Invoice_number': data['Invoice_number']?.toString() ?? '',
        'Invoice_date': data['Invoice_date']?.toString() ?? '',
        'grn_numbers': jsonEncode(data['grn_numbers'] ?? []),
      };
      request.fields.addAll(fields);
      log('Request fields: $fields');

      // Add credit note files
      final creditNumbers = data['credit_no'] as List<dynamic>? ?? [];
      if (creditNoteFiles.isNotEmpty) {
        for (int i = 0; i < creditNoteFiles.length; i++) {
          final file = creditNoteFiles[i];
          if (file.path != null) {
            log(
              'Adding credit_note_copy file: ${file.path}, name: ${file.name}',
            );
            final fileHandle = File(file.path!);
            if (await fileHandle.exists()) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  'credit_note_copy',
                  file.path!,
                  filename: file.name,
                ),
              );
            } else {
              log('credit_note_copy file does not exist: ${file.path}');
              throw Exception('Credit note copy file not found: ${file.path}');
            }
          } else {
            log('credit_note_copy file path is null');
          }
        }
      } else {
        log('No credit note files to add');
      }

      // Add GRN copy files
      final grnNumbers = data['grn_numbers'] as List<dynamic>? ?? [];
      if (grnFiles.isNotEmpty) {
        if (grnFiles.length != grnNumbers.length) {
          log(
            'Validation failed: Number of GRN files (${grnFiles.length}) does not match number of GRN numbers (${grnNumbers.length})',
          );
          throw Exception(
            'Number of GRN files must match number of GRN numbers',
          );
        }
        for (int i = 0; i < grnFiles.length; i++) {
          final file = grnFiles[i];
          if (file.path != null) {
            log('Adding grn_copy file: ${file.path}, name: ${file.name}');
            final fileHandle = File(file.path!);
            if (await fileHandle.exists()) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  'grn_copy',
                  file.path!,
                  filename: file.name,
                ),
              );
            } else {
              log('grn_copy file does not exist: ${file.path}');
              throw Exception('GRN copy file not found: ${file.path}');
            }
          } else {
            log('grn_copy file path is null');
          }
        }
      } else {
        log('No GRN files to add');
      }

      // Add MRN copy file
      if (mrnCopyFile.value != null && mrnCopyFile.value!.path != null) {
        log(
          'Adding mrn_copy file: ${mrnCopyFile.value!.path}, name: ${mrnCopyFile.value!.name}',
        );
        final file = File(mrnCopyFile.value!.path!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'mrn_copy',
              mrnCopyFile.value!.path!,
              filename: mrnCopyFile.value!.name,
            ),
          );
        } else {
          log('mrn_copy file does not exist: ${mrnCopyFile.value!.path}');
          throw Exception(
            'MRN copy file not found: ${mrnCopyFile.value!.path}',
          );
        }
      } else {
        log('No mrn_copy file to add');
      }

      // Log request details
      log('Request URL: ${request.url}');
      log('Request fields: ${request.fields}');
      log(
        'Request files: ${request.files.map((f) => '${f.field}: ${f.filename}').toList()}',
      );

      // Send the request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      log('Response status: ${response.statusCode}');
      log('Response body: $responseData');

      // Handle response
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        log('Parsed response: $jsonResponse');
        if (jsonResponse['status'] == 'true') {
          log('Submission successful: ${jsonResponse['message']}');
          Get.snackbar(
            'Success',
            'Inward Verification Submitted Successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          await controller.refreshDetails(context: context, id: id);
          Navigator.pop(context);
        } else {
          log('Submission failed: ${jsonResponse['message']}Q');
          Get.snackbar(
            'Error',
            jsonResponse['message'] ?? 'Failed to submit inward verification',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        log('Server error: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Server error: ${response.statusCode}',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      log('Error during submission: $e', stackTrace: stackTrace);
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<String>? getFileNames(String field) {
    switch (field) {
      case 'credit_note_copy':
        return creditNoteFiles.map((file) => file.name).toList();
      case 'grn_copy':
        return grnFiles.map((file) => file.name).toList();
      case 'mrn_copy':
        return mrnCopyFile.value != null ? [mrnCopyFile.value!.name] : null;
      default:
        return null;
    }
  }
}
