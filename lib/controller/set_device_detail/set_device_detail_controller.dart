import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trailo/core/network/exceptions.dart';
import 'package:trailo/core/network/networkcall.dart';
import 'package:trailo/core/urls.dart';
import 'package:trailo/model/set_device/set_device_detail_response.dart';
import 'package:trailo/utility/app_colors.dart';

class SetDeviceDetailsController extends GetxController {
  var isLoading = false.obs;
  RxString fcmToken = ''.obs;

  @override
  void onInit() {
    super.onInit();

    _initializeAndSetDevice();
  }

  Future<void> _initializeAndSetDevice() async {
    setDeviceDetail();
  }

  // -----------------------------------------------------------------
  // LOGIN METHOD
  // -----------------------------------------------------------------
  // -----------------------------------------------------------------
  // LOGIN METHOD
  // -----------------------------------------------------------------
  Future<void> setDeviceDetail({
    BuildContext? context,

    // required String? deviceToken,
  }) async {
    try {
      final deviceDetails = await _getDeviceInfo();
      final permissionDetails = await _getPermissionStatus();

      final jsonBody = {
        "device_id": deviceDetails["device_id"] ?? "unknown",
        "device_details": deviceDetails,
        "permission_details": permissionDetails,
      };

      log(jsonEncode(jsonBody));

      isLoading.value = true;

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.setDeviceDetailsApi,
        Networkutility.setDeviceDetails,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        // Properly parse the list using your helper function
        List<SetDeviceDetailResponse> response =
            setDeviceDetailResponseFromJson(jsonEncode(list));

        if (response[0].status == true) {
        } else if (response[0].status == false) {
          // Use actual error or message from API
        }
      } else {
        Get.snackbar(
          'Server error',
          "No response from server",
          snackPosition: SnackPosition.BOTTOM,
        );
        // AppSnackbarStyles.showError(
        //   title: 'Server Error',
        //   message: 'No response from server',
        // );
      }
    } on NoInternetException catch (e) {
    
      log('NoInternetException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
    
      log('TimeoutException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
  
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
    
      log('ParseException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
  
      log('Unexpected error: $e');
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

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "platform": "Android",
        "device_id": androidInfo.id,
        "model": androidInfo.model,
        "brand": androidInfo.brand,
        "version": androidInfo.version.release,
        "sdk_int": androidInfo.version.sdkInt,
        "app_version": packageInfo.version,
        "fcm_token": fcmToken.value,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "platform": "iOS",
        "device_id": iosInfo.identifierForVendor ?? "unknown",
        "model": iosInfo.model,
        "name": iosInfo.name,
        "version": iosInfo.systemVersion,
        "app_version": packageInfo.version,
      };
    }
    return {
      "platform": "Unknown",
      "device_id": "unknown",
      "app_version": packageInfo.version,
    };
  }

  Future<Map<String, bool>> _getPermissionStatus() async {
    try {
      return {
        "camera": await Permission.camera.isGranted,
        "photos": await Permission.photos.isGranted,
        "storage": await Permission.storage.isGranted,
        "notification": await Permission.notification.isGranted,
        "manageExternalStorage": Platform.isAndroid
            ? await Permission.manageExternalStorage.isGranted
            : false,
      };
    } catch (e) {
      return {
        "camera": false,
        "photos": false,
        "storage": false,
        "notification": false,
        "manageExternalStorage": false,
      };
    }
  }

  Future<void> refreshData() async {
    // Reset filters

    await setDeviceDetail(context: Get.context);
  }

  // @override
  // void onClose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   emailFocusNode.dispose();
  //   passwordFocusNode.dispose();
  //   super.onClose();
  // }
}
