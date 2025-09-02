import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/createjson/creatjson.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/network/privilege_service.dart';
import '../../core/urls.dart';
import '../../model/login/get_login_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class LoginController extends GetxController {
  RxBool isLoading = true.obs;
  final PrivilegeService _privilegeService = PrivilegeService();
  Future<void> login({
    BuildContext? context,
    required String? mobile,
    required String? password,
    // required String? token,
  }) async {
    try {
      final jsonBody = Createjson().createJsonForGetLogin(
        mobile.toString(),
        password.toString(),
      );

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.loginApi,
        Networkutility.login,
        jsonBody,
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetLoginResponse> response = List.from(list);
        log(response[0].data!.mobileNumber);
        if (response[0].status == "true") {
          final user = response[0].data;
          bool isAdmin = user!.loginType == "1";
          log('User isAdmin: $isAdmin');
          log('User Type: ${user.userType}');
          await AppUtility.setUserInfo(
            user!.employeeName,
            user.mobileNumber,
            user.userType
                .toString(), //user_type=1for and  user_type=2 for sales employee
            user.id.toString(),
            isAdmin,
            [], // Will be updated to ['dashboard'] by AppUtility
          );
          // Fetch privileges for non-admin users
          List<String> privileges = [];
          if (!isAdmin) {
            final privilegeResponse = await _privilegeService.fetchPrivileges(
              context!,
            );
            if (privilegeResponse != null) {
              privileges = privilegeResponse.data;
              log('Privileges fetched: $privileges');
            } else {
              privileges = ['dashboard']; // Default privilege if fetch fails
              log('No privileges fetched, setting default: [dashboard]');
            }
            // Update privileges in AppUtility
            await AppUtility.updatePrivileges(privileges);
          } else {
            log('Admin user: Skipping privilege fetch, full access granted');
          }
          Get.snackbar(
            'Success',
            'Login successful!',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          Get.offNamed(AppRoutes.home);
          // Get.offNamed('/dashboard');
        } else if (response[0].status == "false") {
          Get.snackbar(
            'Failed',
            "Your mobile number or password is incorrect.\nPlease try again.",
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
}
