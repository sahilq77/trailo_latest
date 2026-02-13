import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trailo/controller/outward/packed_outword/packed_by_list_controller.dart';
import 'package:trailo/core/network/exceptions.dart' show TimeoutException;
import 'package:trailo/model/packed_by_list/packed_by_list_response.dart';
import 'package:trailo/utility/app_colors.dart';
import '../../../common/securetextinputformatter.dart';
import '../../../utility/app_routes.dart';
import '../../../utility/date_formater.dart';

class PackedByOutwardDetailScreen extends StatefulWidget {
  const PackedByOutwardDetailScreen({super.key});

  @override
  State<PackedByOutwardDetailScreen> createState() =>
      _PackedByOutwardDetailScreenState();
}

class _PackedByOutwardDetailScreenState
    extends State<PackedByOutwardDetailScreen> {
  PackedByListData? packedByid;
  final controller = Get.find<PackedByListController>();
  String? srNo;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      packedByid = arguments['packedby_detail'] as PackedByListData?;
      srNo = arguments['sr_no'] as String?;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (packedByid != null && packedByid!.id.isNotEmpty) {
          controller.fetchPackedByDetails(
            context: context,
            id: packedByid!.id,
            reset: true,
          );
        } else {
          controller.errorMessaged.value = 'Invalid outward ID';
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.errorMessaged.value = 'No arguments provided';
      });
    }
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

  Color _verificationColor(int? status) {
    switch (status) {
      case 1:
        return AppColors.secondary;
      case 2:
        return AppColors.success;
      case 3:
        return Colors.deepPurpleAccent;
      default:
        return AppColors.primary;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Packed By Details: ${srNo ?? "N/A"}')),
      body: RefreshIndicator(
        onRefresh: () async {
          if (packedByid != null && packedByid!.id.isNotEmpty) {
            await Future.any([
              controller.refreshDetails(context: context, id: packedByid!.id),
              Future.delayed(
                const Duration(seconds: 10),
                () => throw TimeoutException('Refresh timed out'),
              ),
            ]);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (controller.isLoadingd.value) {
              return _buildShimmer();
            }
            if (controller.errorMessaged.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      controller.errorMessaged.value,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (packedByid != null && packedByid!.id.isNotEmpty) {
                          controller.fetchPackedByDetails(
                            context: context,
                            id: packedByid!.id,
                            reset: true,
                          );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (controller.packedByDetail.isEmpty) {
              return const Center(
                child: Text(
                  'No details available',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final packedBy = controller.packedByDetail.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildDetailRow('Sr. No.', srNo ?? 'N/A'),
                      _buildDetailRow(
                        'Date',
                        packedBy.orderDate != null
                            ? DateFormater.formatDate(
                                packedBy.orderDate.toString(),
                              )
                            : 'N/A',
                      ),
                      _buildDetailRow(
                        'Company Name',
                        packedBy.companyName ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Division',
                        packedBy.divisionName ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Process Type',
                        _processType(
                          int.tryParse(packedBy.processType ?? '0') ?? 0,
                        ),
                      ),
                      _buildDetailRow(
                        'Customer Name',
                        packedBy.customerName?.isNotEmpty == true
                            ? packedBy.customerName!
                            : 'N/A',
                      ),
                      _buildDetailRow(
                        'Issue Name',
                        packedBy.salesTeamEmployeeName?.isNotEmpty == true
                            ? packedBy.salesTeamEmployeeName!
                            : 'N/A',
                      ),
                      _buildDetailRow(
                        'Order Date',
                        packedBy.orderDate != null
                            ? DateFormater.formatDate(
                                packedBy.orderDate.toString(),
                              )
                            : 'N/A',
                      ),
                      _buildDetailRow('Status', packedBy.statusName ?? 'N/A'),
                      _buildDetailRow(
                        'Invoice Date',
                        packedBy.invoiceDateProcess != null
                            ? DateFormater.formatDate(
                                packedBy.invoiceDateProcess.toString(),
                              )
                            : 'N/A',
                      ),
                      _buildDetailRow(
                        'Invoice Number',
                        packedBy.invoiceNumberProcess ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Added By',
                        '${packedBy.employeeName ?? ''} ${packedBy.salesEmployeeName ?? ''}',
                      ),
                      _buildDetailRow(
                        'Invoice Generated By',
                        '${packedBy.employeeName ?? ''}${packedBy.salesEmployeeName ?? ''}',
                      ),
                      packedBy.orderCopy != null &&
                              packedBy.orderCopy!.isNotEmpty
                          ? _viewButton('Order Copy', () {
                              _handleViewDocument(
                                packedBy.orderCopy,
                                'Order Copy',
                              );
                            })
                          : _buildDetailRow('Order Copy', '-'),
                      packedBy.invoiceCopyNew != null &&
                              packedBy.invoiceCopyNew!.isNotEmpty
                          ? _viewButton('Invoice Copy', () {
                              _handleViewDocument(
                                packedBy.invoiceCopyNew,
                                'Invoice Copy',
                              );
                            })
                          : _buildDetailRow('Invoice Copy', '-'),
                      _verificationButton(
                        'Verification',
                        _verificationLabel(
                          int.tryParse(packedBy.verificationStatus ?? '') ?? 0,
                        ),
                        _verificationColor(
                          int.tryParse(packedBy.verificationStatus ?? '') ?? 0,
                        ),
                        () {
                          showVerificationDialog(
                            context,
                            packedBy.id.toString(),
                            packedBy.invoiceNumberProcess ?? '',
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: packedBy.orderStatus == "0"
                              ? () {
                                  Get.toNamed(
                                    AppRoutes.stockmovement,
                                    arguments: packedBy,
                                  );
                                }
                              : null,
                          label: const Text('Stock Movement'),
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: packedBy.orderStatus == "1"
                              ? () {
                                  Get.toNamed(
                                    AppRoutes.outwardmovement,
                                    arguments: packedBy,
                                  );
                                }
                              : null,
                          label: const Text('Delivery Confirmation'),
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
            );
          }),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 10,
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
                  Container(width: 150, height: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Container(height: 20, color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleViewDocument(String? filePath, String documentType) {
    try {
      if (filePath == null || filePath.isEmpty) {
        // Get.snackbar('Error', 'No $documentType available to view');
        return;
      }

      final url = '${controller.url.value}$filePath';
      final lowercaseFilePath = filePath.toLowerCase();

      if (lowercaseFilePath.endsWith('.pdf')) {
        Get.toNamed(AppRoutes.viewpdf, arguments: url);
      } else if (lowercaseFilePath.endsWith('.jpg') ||
          lowercaseFilePath.endsWith('.png') ||
          lowercaseFilePath.endsWith('.jpeg')) {
        Get.toNamed(AppRoutes.viewImage, arguments: url);
      } else {
        //  Get.snackbar('Error', 'Unsupported file type for $documentType');
      }
    } catch (e) {
      // Get.snackbar('Error', 'Failed to open $documentType');
    }
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
                  const Text(": ", style: TextStyle(fontSize: 15)),
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

  void showVerificationDialog(BuildContext context, String id, String invNo) {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController invoiceController = TextEditingController(
      text: invNo,
    );
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              title: const Text('Verification Details'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: invNo.isNotEmpty
                              ? invNo
                              : 'Invoice Number',
                          hintText: 'N/A',
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: reasonController,
                        inputFormatters: [SecureTextInputFormatter.deny()],
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Reason ',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          hintText: 'Enter Reason',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reason';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await controller.setChecked(
                        id: id,
                        context: context,
                        invNo: invNo,
                        reason: reasonController.text,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
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
                  const Text(": ", style: TextStyle(fontSize: 15)),
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
}
