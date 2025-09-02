import 'package:get/get.dart';
import 'package:trailo/controller/inward/inward_list_controller.dart';
import 'package:trailo/controller/outward/completed_order_list_controller.dart';
import 'package:trailo/controller/outward/outward_list_controller.dart';
import 'package:trailo/controller/outward/picked_by_list_controller.dart';

class InwardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<InwardListController>(
      InwardListController(),
    ); // Use Get.put for singleton
  }
}
