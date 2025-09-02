import 'package:get/get.dart';
import 'package:trailo/controller/outward/outward_list_controller.dart';

class OutwardListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<OutwardListController>(
      OutwardListController(),
    ); // Use Get.put for singleton
  }
}
