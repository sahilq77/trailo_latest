import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/customer/change_pass/get_change_password_response.dart';
import '../../../core/network/createjson/creatjson.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../model/customer/change_pass/get_verify_old_password_response.dart';
import '../../../model/login/get_login_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_routes.dart';
import '../../../utility/app_utility.dart';

class VerifyOldPasswordController extends GetxController {
  RxBool isLoading = true.obs;

  Future<void> verifyMobilePass({
    BuildContext? context,
    required String? mobile,

    required String? oldpass,
  }) async {
    try {
      final jsonBody = {"mobile_number": mobile, "password": oldpass};

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.checkOldPassApi,
        Networkutility.checkOldPass,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetVerifyOldPassResponse> response = List.from(list);
        // log(response[0].data.mobileNumber);
        if (response[0].status == "true") {
          // final user = response[0]
          // log("userid${user.userid}");
          // await AppUtility.setUserInfo(
          //   user.employeeName,
          //   user.mobileNumber,
          //   "",
          //   user.id.toString(),
          // );

          Get.snackbar(
            'Success',
            'Mobile Number and Password Verify Successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          Get.toNamed(
            AppRoutes.changePassword,
            arguments: {
              "mobile": mobile.toString(),
              "old_pass": oldpass.toString(),
            },
          );
          // Get.offNamed('/dashboard');
        } else if (response[0].status == "false") {
          Get.snackbar(
            'Failed',
            "You entered mobile number or password is incorrect.\nPlease try again.",
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

  Future<void> changePassword({
    BuildContext? context,
    required String? mobile,
    required String? oldPassword,
    required String? newPassword,

    // required String? token,
  }) async {
    try {
      final jsonBody = {
        "mobile_number": mobile,
        "original_password": oldPassword,

        "new_password": newPassword,
        "confirm_password": newPassword,
      };

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.changePassApi,
        Networkutility.changePass,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetChangeResponse> response = List.from(list);
        // log(response[0].data.mobileNumber);

        if (response[0].status == "true") {
          // final user = response[0].data;
          // log("userid${user.userid}");
          // await AppUtility.setUserInfo(
          //   user.employeeName,
          //   user.mobileNumber,
          //   "",
          //   user.id.toString(),
          // );

          Get.snackbar(
            'Success',
            'Password Change Successfully',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          Get.offAllNamed(AppRoutes.customerLogin);
          // Get.offNamed('/dashboard');
        } else {
          Get.snackbar(
            'Error',
            response[0].message,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      } else {
        Get.back();
        Get.snackbar(
          'Error',
          'Wrong Mobile Number',
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
