import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/customer/login/get_customer_login_response.dart';

import '../../../core/network/createjson/creatjson.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../model/login/get_login_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_routes.dart';
import '../../../utility/app_utility.dart';

class CustomerLoginController extends GetxController {
  RxBool isLoading = true.obs;
  //final PrivilegeService _privilegeService = PrivilegeService();
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
        Networkutility.customerLoginApi,
        Networkutility.customerLogin,
        jsonBody,
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetCutsomerLoginResponse> response = List.from(list);

        if (response[0].status == "true") {
          final user = response[0].data;
          // bool isAdmin = user!.loginType == "1";

          log('User Type: ${user!.userType}');
          log(response[0].data!.mobileNumber1);
          await AppUtility.setUserInfo(
            user.customerName,
            user.mobileNumber1,
            user.userType
                .toString(), //user_type=1for and  user_type=2 for sales employee
            user.id.toString(),
            false,
            [], // Will be updated to ['dashboard'] by AppUtility
          );

          Get.snackbar(
            'Success',
            'Log in successful!',
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          if (user.userType == "3") {
            Get.offAllNamed(AppRoutes.customerHome);
          } else {
            Get.offAllNamed(AppRoutes.home);
          }
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
