import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/createjson/creatjson.dart';
import '../../core/network/exceptions.dart';
import '../../core/network/networkcall.dart';
import '../../core/urls.dart';
import '../../model/login/get_login_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';
import '../../utility/custom_flushbar.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = true.obs;

  Future<void> verifyMobile({
    BuildContext? context,
    required String? mobile,

    // required String? token,
  }) async {
    try {
      final jsonBody = {"mobile_number": mobile};

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.forgotPasswordApi,
        Networkutility.forgotPassword,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetLoginResponse> response = List.from(list);
        // log(response[0].data.mobileNumber);
        if (response[0].status == "true") {
          final user = response[0].data;
          // log("userid${user.userid}");
          // await AppUtility.setUserInfo(
          //   user.employeeName,
          //   user.mobileNumber,
          //   "",
          //   user.id.toString(),
          // );

          CustomFlushbar.flushBarSuccessMessage(
            'Success',
            'Mobile Number Verify Successfully',
            context!,
          );
          Get.toNamed(
            AppRoutes.newspassword,
            arguments: user!.mobileNumber.isNotEmpty
                ? user!.mobileNumber.toString()
                : user!.customerMobile.toString(),
          );
          // Get.offNamed('/dashboard');
        } else if (response[0].status == "false") {
          CustomFlushbar.flushBarErrorMessage(
            'Failed',
            "You entered mobile number is incorrect.\nPlease try again.",
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

  Future<void> changePassword({
    BuildContext? context,
    required String? mobile,
    required String? password,

    // required String? token,
  }) async {
    try {
      final jsonBody = {"mobile_number": mobile, "password": password};

      isLoading.value = true;
      // ProgressDialog.showProgressDialog(context);
      // final jsonBody = Createjson().createJsonForLogin(
      //   mobileNumber.value,
      //   'dummy_push_token', // Replace with actual push token
      //   'dummy_device_id', // Replace with actual device ID
      //   password.value,
      // );
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.forgotPasswordApi,
        Networkutility.forgotPassword,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetLoginResponse> response = List.from(list);
        // log(response[0].data.mobileNumber);
        if (response[0].status == "true") {
          final user = response[0].data;
          // log("userid${user.userid}");
          // await AppUtility.setUserInfo(
          //   user.employeeName,
          //   user.mobileNumber,
          //   "",
          //   user.id.toString(),
          // );

          CustomFlushbar.flushBarSuccessMessage(
            'Success',
            'Password Change Successfully',
            context!,
          );
          Get.offNamed(AppRoutes.login);
          // Get.offNamed('/dashboard');
        } else {
          CustomFlushbar.flushBarErrorMessage(
            'Error',
            response[0].message,
            context!,
          );
        }
      } else {
        Get.back();
        CustomFlushbar.flushBarErrorMessage(
          'Error',
          'Wrong Mobile Number',
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
}