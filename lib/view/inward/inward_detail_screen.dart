import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trailo/model/inward_list/get_inward_list_response.dart';
import 'package:trailo/utility/app_colors.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/view/inward/inward_list.dart';
import '../../controller/inward/inward_list_controller.dart';
import '../../core/network/exceptions.dart';
import '../../utility/app_utility.dart';

class InwardDetailScreen extends StatefulWidget {
  const InwardDetailScreen({super.key});

  @override
  State<InwardDetailScreen> createState() => _InwardDetailScreenState();
}

class _InwardDetailScreenState extends State<InwardDetailScreen> {
  final controller = Get.put(InwardListController());
  InwardListData? inwardid;
  int? srNo; // Add variable to store serial number

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      setState(() {
        inwardid = arguments['inward'] as InwardListData?;
        srNo = arguments['srNo'] as int?;
      });
      if (inwardid != null && inwardid!.id.isNotEmpty) {
        controller.fetchInwardDetail(
          context: context,
          id: inwardid!.id,
          reset: true,
        );
      } else {
        controller.errorMessaged.value = 'Invalid inward ID';
      }
    } else {
      controller.errorMessaged.value = 'No arguments provided';
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
            'Are you sure you want to delete Inward Number: ${inwardid?.inwardNumber ?? 'N/A'}?',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inward Details: ${srNo?.toString() ?? "N/A"}'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (inwardid != null && inwardid!.id.isNotEmpty) {
            await Future.any([
              controller.refreshDetails(context: context, id: inwardid!.id),
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
                        if (inwardid != null && inwardid!.id.isNotEmpty) {
                          controller.fetchInwardDetail(
                            context: context,
                            id: inwardid!.id,
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
            if (controller.inwardDetail.isEmpty) {
              return const Center(
                child: Text(
                  'No details available',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final inward = controller.inwardDetail.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildDetailRow('Sr. No.', srNo?.toString() ?? 'N/A'),
                      _buildDetailRow(
                        'Outward. No.',
                        inward.inwardNumber?.toString() ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Date of Receipt',
                        inward.receiptDate != null
                            ? formatDate(inward.receiptDate.toString())
                            : 'N/A',
                      ),
                      _buildDetailRow(
                        'Inward Number',
                        inward.inwardNumber ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Company Name',
                        inward.companyName ?? 'N/A',
                      ),
                      _buildDetailRow('Division', inward.divisionName ?? 'N/A'),
                      _buildDetailRow(
                        'Transport',
                        inward.transportName?.isNotEmpty == true
                            ? inward.transportName!
                            : '-',
                      ),
                      _buildDetailRow(
                        'LR Date',
                        inward.lrDate != null
                            ? formatDate(inward.lrDate.toString())
                            : 'N/A',
                      ),
                      _buildDetailRow(
                        'Freight Amount',
                        '₹${inward.freightAmount ?? '0'}',
                      ),
                      _buildDetailRow(
                        'Claim',
                        inward.claim == "0" ? "No" : "Yes",
                      ),
                      _buildDetailRow('Status', inward.statusName ?? 'N/A'),
                      _buildDetailRow(
                        'Customer/Vendor',
                        "${inward.customerName ?? ''}${inward.vendorName ?? ''}",
                      ),
                      _buildDetailRow(
                        'Debit Note No.',
                        inward.debitNoteNumber?.isNotEmpty == true
                            ? inward.debitNoteNumber!
                            : '-',
                      ),
                      _buildDetailRow(
                        'Debit Note Date',
                        inward.debitNoteDate != null
                            ? formatDate(inward.debitNoteDate.toString())
                            : '-',
                      ),
                      _buildDetailRow(
                        'Invoice No.',
                        inward.vendorInvoiceNumber?.isNotEmpty == true
                            ? inward.vendorInvoiceNumber!
                            : '-',
                      ),
                      _buildDetailRow(
                        'Invoice Date',
                        inward.vendorInvoiceDate != null
                            ? formatDate(inward.vendorInvoiceDate.toString())
                            : '-',
                      ),
                      inward.lrCopy != null && inward.lrCopy!.isNotEmpty
                          ? _viewButton('LR Copy', "View", () {
                              try {
                                final filePath = inward.lrCopy!.toLowerCase();
                                final url = '${controller.url.value}${inward.lrCopy}';
                                if (filePath.endsWith('.pdf')) {
                                  Get.toNamed(AppRoutes.viewpdf, arguments: url);
                                } else if (filePath.endsWith('.jpg') ||
                                    filePath.endsWith('.png') ||
                                    filePath.endsWith('.jpeg')) {
                                  Get.toNamed(AppRoutes.viewImage, arguments: url);
                                }
                              } catch (e) {}
                            })
                          : _buildDetailRow('LR Copy', '-'),
                      inward.debitNoteCopy != null && inward.debitNoteCopy!.isNotEmpty
                          ? _viewButton('Debit Note Copy', "View", () {
                              try {
                                final filePath = inward.debitNoteCopy!.toLowerCase();
                                final url = '${controller.url.value}${inward.debitNoteCopy}';
                                if (filePath.endsWith('.pdf')) {
                                  Get.toNamed(AppRoutes.viewpdf, arguments: url);
                                } else if (filePath.endsWith('.jpg') ||
                                    filePath.endsWith('.png') ||
                                    filePath.endsWith('.jpeg')) {
                                  Get.toNamed(AppRoutes.viewImage, arguments: url);
                                }
                              } catch (e) {}
                            })
                          : _buildDetailRow('Debit Note Copy', '-'),
                      inward.invoiceCopy != null && inward.invoiceCopy!.isNotEmpty
                          ? _viewButton('Invoice Copy', "View", () {
                              try {
                                final filePath = inward.invoiceCopy!.toLowerCase();
                                final url = '${controller.url.value}${inward.invoiceCopy}';
                                if (filePath.endsWith('.pdf')) {
                                  Get.toNamed(AppRoutes.viewpdf, arguments: url);
                                } else if (filePath.endsWith('.jpg') ||
                                    filePath.endsWith('.png') ||
                                    filePath.endsWith('.jpeg')) {
                                  Get.toNamed(AppRoutes.viewImage, arguments: url);
                                }
                              } catch (e) {}
                            })
                          : _buildDetailRow('Invoice Copy', '-'),
                      _viewButton('Credit Note/ GRN Details', "View", () {
                        Get.toNamed(AppRoutes.viewNote, arguments: inward.id);
                      }),
                      SizedBox(height: 5),
                      AppUtility.userType == "1"
                          ? ElevatedButton.icon(
                              onPressed: inward.isVerified == "1"
                                  ? null
                                  : () {
                                      Get.toNamed(
                                        AppRoutes.inwardverification,
                                        arguments: inward,
                                      );
                                    },
                              icon: const Icon(Icons.check),
                              label: const Text('Verification'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppUtility.userType == "1"
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  // Show confirmation dialog before deletion
                                  bool? confirmDelete =
                                      await _showDeleteConfirmationDialog(
                                        context,
                                      );
                                  if (confirmDelete ?? false) {
                                    controller.deleteInward(
                                      id: inward.id,
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.toNamed(
                                    AppRoutes.editInward,
                                    arguments: {
                                      'inward': inward,
                                      'srNo': 0, // Pass the serial number
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
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

  Card _viewButton(String label, String title, VoidCallback press) {
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
                                  title,
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

  String formatDate(String inputDate) {
    try {
      DateTime dateTime = DateTime.parse(inputDate);
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      return formatter.format(dateTime);
    } catch (e) {
      return 'N/A';
    }
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
