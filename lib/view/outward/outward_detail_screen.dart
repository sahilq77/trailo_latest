import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trailo/model/outward_list/get_outward_list_response.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/utility/date_formater.dart';
import 'package:trailo/utility/app_colors.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer package

import '../../controller/outward/outward_list_controller.dart';

class OutwardDetailScreen extends StatefulWidget {
  const OutwardDetailScreen({super.key});

  @override
  State<OutwardDetailScreen> createState() => _OutwardDetailScreenState();
}

class _OutwardDetailScreenState extends State<OutwardDetailScreen> {
  OutwardListData? outwardId;
  String? srNo;
  final controller = Get.put(OutwardListController());

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      setState(() {
        outwardId = arguments['outward_detail'] as OutwardListData?;
        srNo = arguments['sr_no'] as String?;
      });
      if (outwardId != null && outwardId!.id.isNotEmpty) {
        controller.fetchOutwardDetails(
          context: context,
          id: outwardId!.id,
          reset: true,
        );
      } else {
        controller.errorMessageDetail.value = 'Invalid outward ID';
      }
    } else {
      controller.errorMessageDetail.value = 'No arguments provided';
    }
  }

  // Method to show delete confirmation dialog
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevents closing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to delete Outward ID: ${outwardId!.id}?',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _verificationLabel(int? status) {
    switch (status) {
      case 0:
        return 'Transfer for Picked';
      case 1:
        return 'Transfer for Checked';
      case 2:
        return 'Transfer for Packaging';
      case 3:
        return 'Transfer for Checked';
      default:
        return 'Unknown';
    }
  }

  String _processType(int status) {
    switch (status) {
      case 0:
        return 'Sales Order';
      case 1:
        return 'Free Issue';
      case 2:
        return 'Sample';
      case 3:
        return 'Transfer';
      default:
        return 'Unknown';
    }
  }

  Color _verificationColor(int status) {
    switch (status) {
      case 0:
        return AppColors.secondary;
      case 1:
        return AppColors.success;
      case 2:
        return Colors.deepPurpleAccent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Outward Details: ${srNo}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoadingDetail.value) {
                  return _buildShimmerEffect();
                } else if (controller.errorMessageDetail.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessageDetail.value,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  );
                } else if (controller.outwardDetail.isEmpty) {
                  return Center(
                    child: Text(
                      'No details available',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.refreshOutwardDetails(
                      context: context,
                      id: outwardId!.id,
                      showLoading: true,
                    );
                  },
                  child: ListView(
                    children: [
                      _buildDetailRow('Sr. No.', srNo.toString()),
                      _buildDetailRow(
                        'Date',
                        "${DateFormater.formatDate(controller.outwardDetail[0].orderDate.toString())}",
                      ),
                      _buildDetailRow(
                        'Company Name',
                        controller.outwardDetail[0].companyName,
                      ),
                      _buildDetailRow(
                        'Division',
                        controller.outwardDetail[0].divisionName,
                      ),
                      _buildDetailRow(
                        'Process Type',
                        _processType(
                          int.parse(controller.outwardDetail[0].processType),
                        ),
                      ),
                      _buildDetailRow(
                        'Customer Name',
                        controller.outwardDetail[0].customerName.isNotEmpty
                            ? controller.outwardDetail[0].customerName
                            : "N/A",
                      ),
                      _buildDetailRow(
                        'Issue Name',
                        controller.outwardDetail[0].salesTeamEmployeeName !=
                                    null &&
                                controller
                                    .outwardDetail[0]
                                    .salesTeamEmployeeName!
                                    .isNotEmpty
                            ? controller.outwardDetail[0].salesTeamEmployeeName!
                            : 'N/A',
                      ),
                      _buildDetailRow(
                        'Order Date',
                        DateFormater.formatDate(
                          controller.outwardDetail[0].orderDate.toString(),
                        ),
                      ),
                      _buildDetailRow(
                        'Status',
                        controller.outwardDetail[0].statusName,
                      ),
                      _buildDetailRow(
                        'Invoice Date',
                        "${DateFormater.formatDate(controller.outwardDetail[0].invoiceDateProcess.toString())}",
                      ),
                      _buildDetailRow(
                        'Invoice Number',
                        controller.outwardDetail[0].invoiceNumberProcess,
                      ),
                      _buildDetailRow(
                        'Added By',
                        '${controller.outwardDetail[0].employeeName.toString()} ${controller.outwardDetail[0].salesEmployeeName.toString()}',
                      ),
                      _buildDetailRow(
                        'Invoice Generated By',
                        '${controller.outwardDetail[0].employeeName.toString()}${controller.outwardDetail[0].salesEmployeeName.toString()}',
                      ),
                      _viewButton('Order Copy', () {
                        try {
                          if (controller.outwardDetail.isEmpty ||
                              controller.outwardDetail[0].orderCopy == null) {
                            print('Error: outward or orderCopy is null');
                            Get.snackbar(
                              'Error',
                              'No document available to view',
                            );
                            return;
                          }

                          final filePath = controller.outwardDetail[0].orderCopy
                              .toString()
                              .toLowerCase();
                          final url =
                              '${controller.url.value}${controller.outwardDetail[0].orderCopy}';

                          print('Attempting to open: $url'); // Debug log

                          if (filePath.endsWith('.pdf')) {
                            print('Navigating to PDF viewer');
                            Get.toNamed(AppRoutes.viewpdf, arguments: url);
                          } else if (filePath.endsWith('.jpg') ||
                              filePath.endsWith('.png') ||
                              filePath.endsWith('.jpeg')) {
                            print('Navigating to Image viewer');
                            Get.toNamed(AppRoutes.viewImage, arguments: url);
                          } else {
                            print('Unsupported file type: $filePath');
                            Get.snackbar(
                              'Error',
                              'File not available on server',
                            );
                          }
                        } catch (e) {
                          print('Error in viewButton: $e');
                          Get.snackbar('Error', 'Failed to open document');
                        }
                      }),
                      _viewButton('Invoice Copy', () {
                        try {
                          if (controller.outwardDetail.isEmpty ||
                              controller.outwardDetail[0].invoiceCopyNew ==
                                  null) {
                            print('Error: outward or invoiceCopyNew is null');
                            Get.snackbar(
                              'Error',
                              'No document available to view',
                            );
                            return;
                          }

                          final filePath = controller
                              .outwardDetail[0]
                              .invoiceCopyNew
                              .toString()
                              .toLowerCase();
                          final url =
                              '${controller.url.value}${controller.outwardDetail[0].invoiceCopyNew}';

                          print('Attempting to open: $url'); // Debug log

                          if (filePath.endsWith('.pdf')) {
                            print('Navigating to PDF viewer');
                            Get.toNamed(AppRoutes.viewpdf, arguments: url);
                          } else if (filePath.endsWith('.jpg') ||
                              filePath.endsWith('.png') ||
                              filePath.endsWith('.jpeg')) {
                            print('Navigating to Image viewer');
                            Get.toNamed(AppRoutes.viewImage, arguments: url);
                          } else {
                            print('Unsupported file type: $filePath');
                            Get.snackbar(
                              'Error',
                              'File not available on server',
                            );
                          }
                        } catch (e) {
                          print('Error in viewButton: $e');
                          Get.snackbar('Error', 'Failed to open document');
                        }
                      }),
                      _verificationButton(
                        'Verification',
                        _verificationLabel(
                          int.parse(
                            controller.outwardDetail[0].verificationStatus,
                          ),
                        ),
                        _verificationColor(
                          int.parse(
                            controller.outwardDetail[0].verificationStatus,
                          ),
                        ),
                        () {
                          _showVerificationDialog(context, () {
                            controller.setPicked(
                              id: controller.outwardDetail[0].id,
                              context: context,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        bool? confirmDelete =
                            await _showDeleteConfirmationDialog(context);
                        if (confirmDelete ?? false) {
                          controller.deleteInward(
                            id: controller.outwardDetail[0].id,
                            context: context,
                          );
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.editOutward,
                          arguments: controller.outwardDetail[0],
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer effect widget for loading state
  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 10, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 150, height: 16, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 16, color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showVerificationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Verification'),
          content: const Text(
            'Are you sure you want to proceed with transfer to picked ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _verificationButton(
    String label,
    String buttonLabel,
    Color color,
    VoidCallback press,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Text(": ", style: const TextStyle(fontSize: 15)),
                  GestureDetector(
                    onTap: press,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(1.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: press,
                          splashColor: Colors.white.withOpacity(0.3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              buttonLabel,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card _viewButton(String label, VoidCallback press) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Text(": ", style: const TextStyle(fontSize: 15)),
                  GestureDetector(
                    onTap: () {
                      print("View button tapped");
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(1.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: press,
                          splashColor: Colors.white.withOpacity(0.3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "View",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  semanticsLabel: "View Button",
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
            ),
            const Text(': ', style: TextStyle(fontSize: 15)),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 15),
                maxLines: 3, // Allow up to 3 lines for long text
                overflow: TextOverflow
                    .ellipsis, // Add ellipsis if text exceeds maxLines
                softWrap: true, // Enable text wrapping
              ),
            ),
          ],
        ),
      ),
    );
  }
}
