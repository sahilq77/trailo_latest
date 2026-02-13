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

    // Request camera and notification permissions
    List<Permission> permissionsToRequest = [
      Permission.camera,
      Permission.notification,
    ];

    Map<Permission, PermissionStatus> statuses = await permissionsToRequest
        .request();

    // Check permission statuses
    bool cameraDenied = statuses[Permission.camera]!.isDenied;
    bool cameraPermanentlyDenied =
        statuses[Permission.camera]!.isPermanentlyDenied;
    bool notificationDenied = statuses[Permission.notification]!.isDenied;
    bool notificationPermanentlyDenied =
        statuses[Permission.notification]!.isPermanentlyDenied;

    if ((cameraDenied || cameraPermanentlyDenied) ||
        (notificationDenied || notificationPermanentlyDenied)) {
      // Improved snackbar
      Get.snackbar(
        'Permissions Needed',
        'This app needs camera and notification access to capture customer photos and send notifications. Please grant the permissions.',
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
                notificationPermanentlyDenied) {
              await openAppSettings(); // Open settings if permanently denied
            } else {
              // Retry permission request
              await permissionsToRequest.request();
            }
          },
          child: Text(
            cameraPermanentlyDenied ||
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
      if (AppUtility.userType == "3") {
        Get.offNamed(AppRoutes.customerHome);
      } else {
        Get.offNamed(AppRoutes.home);
      }
    } else {
      Get.offNamed(AppRoutes.welcome);
    }
  }


}
