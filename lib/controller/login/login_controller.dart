import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/utility/custom_flushbar.dart';
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
          CustomFlushbar.flushBarSuccessMessage("Success","Log in successful!", context!);
          // Get.snackbar(
          //   'Success',
          //   'Log in successful!',
          //   backgroundColor: AppColors.success,
          //   colorText: Colors.white,
          // );
          Get.offNamed(AppRoutes.home);
          // Get.offNamed('/dashboard');
        } else if (response[0].status == "false") {
          CustomFlushbar.flushBarErrorMessage(
            "Failed",
            "Your mobile number or password is incorrect. Please try again.",
            context!,
          );
        }
      } else {
        Get.back();
        CustomFlushbar.flushBarErrorMessage(
          "Error",
          "No response from server",
          context!,
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage( "Error",e.message, context!);
    } on TimeoutException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage( "Error",e.message, context!);
    } on HttpException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage( "Error",e.message, context!);
    } on ParseException catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage( "Error",e.message, context!);
    } catch (e) {
      Get.back();
      CustomFlushbar.flushBarErrorMessage( "Error",'Unexpected error: $e', context!);
    } finally {
      isLoading.value = false;
    }
  }
}
