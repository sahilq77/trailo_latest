import 'package:get/get.dart';
import 'package:trailo/controller/outward/completed_order_list_controller.dart';
import 'package:trailo/controller/outward/outward_list_controller.dart';
import 'package:trailo/controller/outward/picked_by_list_controller.dart';

class CompletedOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CompletedOrderListController>(
      CompletedOrderListController(),
    ); // Use Get.put for singleton
  }
}
