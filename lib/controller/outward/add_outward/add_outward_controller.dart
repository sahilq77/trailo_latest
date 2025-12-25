import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:trailo/controller/outward/outward_list_controller.dart';
import 'package:trailo/core/urls.dart';
import 'package:trailo/utility/app_utility.dart';
import 'package:trailo/utility/app_colors.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../core/network/exceptions.dart';

class AddOutwardController extends GetxController {
  final controller = Get.put(OutwardListController());
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var orderCopyFile = Rxn<PlatformFile>();
  var invoiceCopyFile = Rxn<PlatformFile>();

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
              Get.snackbar(
                'Permission Required',
                'Please enable "All Files Access" in system settings to pick files.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.error,
                colorText: Colors.white,
                mainButton: TextButton(
                  onPressed: () {
                    log('Opening system settings for MANAGE_EXTERNAL_STORAGE');
                    openAppSettings();
                  },
                  child: Text(
                    'Open Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
      Get.snackbar(
        'Permission Denied',
        'Storage access is required to pick files.',

        backgroundColor: AppColors.error,
        colorText: Colors.white,
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
          case 'order_copy':
            orderCopyFile.value = result.files.first;
            break;
          case 'invoice_copy_new':
            invoiceCopyFile.value = result.files.first;
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

  Future submitOutwardData({
    Map<String, String>? data,
    bool? edit,
    BuildContext? context,
    String? id,
  }) async {
    try {
      isLoading.value = true;
      log('Submitting Outward data: $data');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.addOutward),
      );

      // Add form fields
      data!.forEach((key, value) {
        if (value.isNotEmpty && value != 'null') {
          log('Adding field $key: $value');
          request.fields[key] = value;
        }
      });

      // Add file uploads using file paths
      if (orderCopyFile.value != null && orderCopyFile.value!.path != null) {
        log('Adding order_copy file: ${orderCopyFile.value!.path}');
        final file = File(orderCopyFile.value!.path!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'order_copy',
              orderCopyFile.value!.path!,
              filename: orderCopyFile.value!.name,
            ),
          );
        } else {
          log('order_copy file does not exist: ${orderCopyFile.value!.path}');
          throw Exception('order_copy file not found');
        }
      } else {
        log('No order_copy file selected or path is null');
      }

      if (invoiceCopyFile.value != null &&
          invoiceCopyFile.value!.path != null) {
        log('Adding invoice_copy_new file: ${invoiceCopyFile.value!.path}');
        final file = File(invoiceCopyFile.value!.path!);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'invoice_copy_new',
              invoiceCopyFile.value!.path!,
              filename: invoiceCopyFile.value!.name,
            ),
          );
        } else {
          log(
            'invoice_copy_new file does not exist: ${invoiceCopyFile.value!.path}',
          );
          throw Exception('invoice_copy_new file not found');
        }
      } else {
        log('No invoice_copy_new file selected or path is null');
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
          await controller.fetchOutwardList(context: context!, reset: true);
          await controller.refreshOutwardList(
            context: context!,
            showLoading:
                false, // Optional: Set to false to avoid showing loading indicator
          );

          if (edit == true) {
            Get.snackbar(
              'Success',
              'Outward Edited Successfully', // Updated message to reflect "Outward"
              backgroundColor: AppColors.success,
              colorText: Colors.white,
            );
            await controller.refreshOutwardDetails(
              context: context,
              id: id ?? "",
            );
            Navigator.pop(context);
          } else {
            Get.offNamed(AppRoutes.outwardList);
            Get.snackbar(
              'Success',
              'Outward Added Successfully', // Updated message to reflect "Outward"
              backgroundColor: AppColors.success,
              colorText: Colors.white,
            );
          }
        }
        // Refresh the OutwardListController data
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
        'Unexpected error: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? getFileName(String field) {
    switch (field) {
      case 'order_copy':
        return orderCopyFile.value?.name;
      case 'invoice_copy_new':
        return invoiceCopyFile.value?.name;

      default:
        return null;
    }
  }
}
