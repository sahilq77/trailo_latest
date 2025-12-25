import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:trailo/controller/outward/packed_outword/packed_by_list_controller.dart';
import 'package:trailo/core/urls.dart';
import 'package:trailo/utility/app_utility.dart';
import 'package:trailo/utility/app_colors.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/utility/custom_flushbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../core/network/exceptions.dart';

class AddOutwordStockMovementController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var lrCopyFile = Rxn<PlatformFile>();
  final controller = Get.put(PackedByListController());
  // Check and request storage permissions based on Android version
  Future<bool> _requestStoragePermission() async {
    log('Checking storage permissions');
    bool granted = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;
      log('Android SDK version: $sdkVersion');

      if (sdkVersion >= 33) {
        // Android 13+: Request granular permissions or MANAGE_EXTERNAL_STORAGE
        var status = await Permission.photos.status;
        if (!status.isGranted) {
          log('Requesting photos permission');
          status = await Permission.photos.request();
        }
        granted = status.isGranted;
        log('Photos permission ${granted ? "granted" : "denied"}');

        // For PDFs, we may need MANAGE_EXTERNAL_STORAGE
        if (!granted) {
          status = await Permission.manageExternalStorage.status;
          if (!status.isGranted) {
            log('Requesting MANAGE_EXTERNAL_STORAGE permission');
            // MANAGE_EXTERNAL_STORAGE requires user to enable in settings
            granted = await Permission.manageExternalStorage
                .request()
                .isGranted;
            if (!granted) {
              log('MANAGE_EXTERNAL_STORAGE denied, prompting system settings');
              CustomFlushbar.flushBarErrorMessage(
                'Permission Required',
                'Please enable "All Files Access" in system settings to pick files.',
                Get.context!,
              );
            } else {
              log('MANAGE_EXTERNAL_STORAGE granted');
              granted = true;
            }
          } else {
            log('MANAGE_EXTERNAL_STORAGE already granted');
            granted = true;
          }
        }
      } else {
        // Android 12 and below: Request storage permission
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          log('Requesting storage permission');
          status = await Permission.storage.request();
        }
        granted = status.isGranted;
        log('Storage permission ${granted ? "granted" : "denied"}');
      }
    } else if (Platform.isIOS) {
      // iOS: Request photos permission
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        log('Requesting photos permission');
        status = await Permission.photos.request();
      }
      granted = status.isGranted;
      log('Photos permission ${granted ? "granted" : "denied"}');
    }

    if (!granted) {
      log('All permissions denied');
      CustomFlushbar.flushBarErrorMessage(
        'Permission Denied',
        'Storage access is required to pick files.',
        Get.context!,
      );
    }
    return granted;
  }

  Future<void> pickFile(String field) async {
    try {
      // Request storage permission before picking files
      if (!await _requestStoragePermission()) {
        log('File picking aborted due to permission denial');
        return;
      }

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
        }
        update();
      } else {
        log('No file selected for field: $field');
      }
    } catch (e, stackTrace) {
      log('Error picking file for $field: $e', stackTrace: stackTrace);
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        'Failed to pick file: $e',
        Get.context!,
      );
    }
  }

  Future<void> submitStockMovementData({
    Map<String, String>? data,
    BuildContext? context,
    required String id,
  }) async {
    try {
      isLoading.value = true;
      log('Submitting inward data: $data');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.addStockMovement),
      );

      // Add form fields
      data!.forEach((key, value) {
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
        print("Status===> ${jsonResponse['status']}");
        if (jsonResponse['status'] == 'true') {
          CustomFlushbar.flushBarSuccessMessage(
            'Success',
            'Stock Movement Added Successfully',
            context!,
          );
          await controller.refreshDetails(context: context, id: id);
          Navigator.pop(context!);
        } else {
          CustomFlushbar.flushBarErrorMessage(
            'Failed',
            'Stock Movement Add Failed',
            context!,
          );
        }
      } else {
        Get.back();
        CustomFlushbar.flushBarErrorMessage(
          'Error',
          'No response from server',
          context!,
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } on TimeoutException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } on HttpException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        context!,
      );
    } on ParseException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context!,
      );
    } catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        'Unexpected error: $e',
        context!,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? getFileName(String field) {
    switch (field) {
      case 'lr_copy':
        return lrCopyFile.value?.name;

      default:
        return null;
    }
  }
}