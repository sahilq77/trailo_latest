import 'package:get/get.dart';
import 'package:trailo/controller/outward/checked_list_controller.dart';
import 'package:trailo/controller/outward/outward_list_controller.dart';
import 'package:trailo/controller/outward/picked_by_list_controller.dart';

class CheckedByOutwardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CheckedListController>(
      CheckedListController(),
    ); // Use Get.put for singleton
  }
}
