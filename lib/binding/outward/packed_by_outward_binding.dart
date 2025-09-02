import 'package:get/get.dart';
import 'package:trailo/controller/outward/outward_list_controller.dart';
import 'package:trailo/controller/outward/packed_outword/packed_by_list_controller.dart';
import 'package:trailo/controller/outward/picked_by_list_controller.dart';

class PackedByOutwardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PackedByListController>(
      PackedByListController(),
    ); // Use Get.put for singleton
  }
}
