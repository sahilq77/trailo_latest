import 'package:get/get.dart';
import 'package:trailo/controller/outward/outward_list_controller.dart';
import 'package:trailo/controller/outward/picked_by_list_controller.dart';

class PickedByOutwardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PickedByListController>(
      PickedByListController(),
    ); // Use Get.put for singleton
  }
}
