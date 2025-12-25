import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trailo/model/global_model/transport/get_all_transport_response.dart';
import 'package:trailo/utility/app_utility.dart';
import '../../../core/network/exceptions.dart';
import '../../../core/network/networkcall.dart';
import '../../../core/urls.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/custom_flushbar.dart';

class TransportController extends GetxController {
  RxList<TransportData> transportList = <TransportData>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  RxString selectedTransportVal = ''.obs; // Initialize as empty string

  static TransportController get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    // Defer fetching until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        fetchTransport(context: Get.context!);
      }
    });
  }

  Future<void> fetchTransport({
    required BuildContext context,
    bool forceFetch = false,
  }) async {
    print("Called");
    if (!forceFetch && transportList.isNotEmpty) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final jsonBody = {"Employee_id": AppUtility.userID};

      List<GetAllTrasnsportResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getAllTransportApi,
                Networkutility.getAllTransport,
                jsonEncode(jsonBody),
                context,
              ) as List<GetAllTrasnsportResponse>?;

      log(
        'Fetch Transports Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          transportList.value = response[0].data;
          log(
            'Transport List Loaded: ${transportList.map((s) => "${s.transportId}: ${s.transportName}").toList()}',
          );
        } else {
          errorMessage.value = response[0].message;
          CustomFlushbar.flushBarErrorMessage(
            'Error',
            response[0].message,
            context,
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        CustomFlushbar.flushBarErrorMessage(
          'Error',
          'No response from server',
          context,
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        context,
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        e.message,
        context,
      );
    } catch (e, stackTrace) {
      errorMessage.value = 'Unexpected error: $e';
      log('Fetch Transport Exception: $e, stack: $stackTrace');
      CustomFlushbar.flushBarErrorMessage(
        'Error',
        'Unexpected error: $e',
        context,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<String> getTransportNames() {
    return transportList.map((s) => s.transportName).toSet().toList();
  }

  String? getTransportId(String cName) {
    return transportList
            .firstWhereOrNull((state) => state.transportName == cName)
            ?.transportId ??
        '';
  }

  String? getTransportNameById(String stateId) {
    return transportList
        .firstWhereOrNull((state) => state.transportId == stateId)
        ?.transportName;
  }
}