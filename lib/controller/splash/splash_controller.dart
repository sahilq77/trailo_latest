import 'dart:io'; // For Platform checks

import 'package:device_info_plus/device_info_plus.dart'; // Ensure this import is present
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';


class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await AppUtility.initialize();

    // Request camera and photos permissions
    List<Permission> permissionsToRequest = [
      Permission.camera,
      Permission.notification,
    ];

    // Conditionally add photos permission based on Android version
    if (Platform.isAndroid) {
      // Check Android SDK version for appropriate permission
      // API 33+ uses READ_MEDIA_IMAGES, below uses READ_EXTERNAL_STORAGE
      if (await _isAndroid13OrAbove()) {
        permissionsToRequest.add(Permission.photos);
      } else {
        permissionsToRequest.add(Permission.storage);
      }
    } else if (Platform.isIOS) {
      permissionsToRequest.add(Permission.photos);
    }

    Map<Permission, PermissionStatus> statuses =
        await permissionsToRequest.request();

    // Check permission statuses
    bool cameraDenied = statuses[Permission.camera]!.isDenied;
    bool cameraPermanentlyDenied =
        statuses[Permission.camera]!.isPermanentlyDenied;
    bool photosDenied =
        statuses.containsKey(Permission.photos) &&
        statuses[Permission.photos]!.isDenied;
    bool photosPermanentlyDenied =
        statuses.containsKey(Permission.photos) &&
        statuses[Permission.photos]!.isPermanentlyDenied;
    bool storageDenied =
        statuses.containsKey(Permission.storage) &&
        statuses[Permission.storage]!.isDenied;
    bool storagePermanentlyDenied =
        statuses.containsKey(Permission.storage) &&
        statuses[Permission.storage]!.isPermanentlyDenied;
    bool notificationDenied = statuses[Permission.notification]!.isDenied;
    bool notificationPermanentlyDenied =
        statuses[Permission.notification]!.isPermanentlyDenied;

    if ((cameraDenied || cameraPermanentlyDenied) ||
        (photosDenied || photosPermanentlyDenied) ||
        (storageDenied || storagePermanentlyDenied) ||
        (notificationDenied || notificationPermanentlyDenied)) {
      // Improved snackbar
      Get.snackbar(
        'Permissions Needed',
        'This app needs camera, gallery, and notification access to capture and upload customer photos and send notifications. Please grant the permissions.',
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition:
            SnackPosition.TOP, // Display at top for better visibility
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.info_outline, color: Colors.white),
        duration: const Duration(seconds: 5),
        animationDuration: const Duration(milliseconds: 400),
        shouldIconPulse: true,
        mainButton: TextButton(
          onPressed: () async {
            if (cameraPermanentlyDenied ||
                photosPermanentlyDenied ||
                storagePermanentlyDenied ||
                notificationPermanentlyDenied) {
              await openAppSettings(); // Open settings if permanently denied
            } else {
              // Retry permission request
              await permissionsToRequest.request();
            }
          },
          child: Text(
            cameraPermanentlyDenied ||
                    photosPermanentlyDenied ||
                    storagePermanentlyDenied ||
                    notificationPermanentlyDenied
                ? 'Open Settings'
                : 'Retry',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // Wait briefly to ensure snackbar is visible
      await Future.delayed(const Duration(seconds: 1));
    }

  //  Proceed with navigation after permission handling
    await Future.delayed(const Duration(seconds: 2));
    if (AppUtility.isLoggedIn) {
      Get.offNamed(AppRoutes.home);
    } else {
      Get.offNamed(AppRoutes.welcome);
    }
  }

  //Helper method to check Android version (API 33+ for READ_MEDIA_IMAGES)
  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      try {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt >=
            33; // Correctly access version.sdkInt
      } catch (e) {
        if (kDebugMode) {
          print('Error checking Android version: $e');
        }
        return false; // Fallback to false if version check fails
      }
    }
    return false;
  }
}
