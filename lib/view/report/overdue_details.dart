import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trailo/controller/pending_overdue/pending_overdue_list_controller.dart';
import 'package:trailo/model/pending_deliveries/get_peding_overdue_list_response.dart';
import 'package:trailo/utility/app_routes.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utility.dart';
import '../../../utility/date_formater.dart';

// PendingOverdueData class definition

class PendingOverdueDetail extends StatefulWidget {
  const PendingOverdueDetail({super.key});

  @override
  State<PendingOverdueDetail> createState() => _PendingOverdueDetailState();
}

class _PendingOverdueDetailState extends State<PendingOverdueDetail> {
  PendingOverdueData? overdue;
  final controller = Get.put(PendingOverdueListController());
  String? srNo; // Add variable to store serial number

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    setState(() {
      overdue = arguments['overdue_detail'] as PendingOverdueData;
      srNo = arguments['sr_no'] as String; // Retrieve serial number
    });
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

  List<Widget> _buildDetailsList() {
    if (AppUtility.userType == "3") {
      return [
        _buildDetailRow('Invoice Number', overdue!.invoiceNumberProcess),
        _buildDetailRow(
          'Invoice Date',
          "${DateFormater.formatDate(overdue!.invoiceDateProcess.toString())}",
        ),
        _buildDetailRow('Division', overdue!.divisionName),
        _buildDetailRow(
          'Customer Name',
          overdue!.customerName.isNotEmpty ? overdue!.customerName : "N/A",
        ),
        _buildDetailRow(
          'Order Date',
          DateFormater.formatDate(overdue!.orderDate.toString()),
        ),

        _buildDetailRow(
          'LR Date',
          "${DateFormater.formatDate(overdue!.LrDate.toString())}",
        ),
        _buildDetailRow('LR Number', overdue!.LrNumber),
        _buildDetailRow(
          'Transport',
          overdue!.transportName.isNotEmpty ? overdue!.transportName : "N/A",
        ),
        overdue!.orderCopy != null && overdue!.orderCopy!.isNotEmpty
            ? _viewButton('Order Copy', () {
                try {
                  final filePath = overdue!.orderCopy.toString().toLowerCase();
                  final url = '${controller.url.value}${overdue!.orderCopy}';
                  if (filePath.endsWith('.pdf')) {
                    Get.toNamed(AppRoutes.viewpdf, arguments: url);
                  } else if (filePath.endsWith('.jpg') ||
                      filePath.endsWith('.png') ||
                      filePath.endsWith('.jpeg')) {
                    Get.toNamed(AppRoutes.viewImage, arguments: url);
                  }
                } catch (e) {
                  print('Error in viewButton: $e');
                }
              })
            : _buildDetailRow('Order Copy', '-'),
        overdue!.invoiceCopyNew != null && overdue!.invoiceCopyNew!.isNotEmpty
            ? _viewButton('Invoice Copy', () {
                try {
                  final filePath = overdue!.invoiceCopyNew
                      .toString()
                      .toLowerCase();
                  final url =
                      '${controller.url.value}${overdue!.invoiceCopyNew}';
                  if (filePath.endsWith('.pdf')) {
                    Get.toNamed(AppRoutes.viewpdf, arguments: url);
                  } else if (filePath.endsWith('.jpg') ||
                      filePath.endsWith('.png') ||
                      filePath.endsWith('.jpeg')) {
                    Get.toNamed(AppRoutes.viewImage, arguments: url);
                  }
                } catch (e) {
                  print('Error in viewButton: $e');
                }
              })
            : _buildDetailRow('Invoice Copy', '-'),
      ];
    } else {
      return [
        _buildDetailRow('Sr. No.', "${srNo}"),
        _buildDetailRow(
          'Date',
          "${DateFormater.formatDate(overdue!.orderDate.toString())}",
        ),
        _buildDetailRow('Company Name', overdue!.companyName),
        _buildDetailRow('Division', overdue!.divisionName),
        _buildDetailRow(
          'Process Type',
          _processType(int.parse(overdue!.processType)),
        ),
        _buildDetailRow(
          'Customer Name',
          overdue!.customerName.isNotEmpty ? overdue!.customerName : "N/A",
        ),
        _buildDetailRow(
          'Transport Name',
          overdue!.transportName.isNotEmpty ? overdue!.transportName : "N/A",
        ),
        _buildDetailRow(
          'Issue Name',
          overdue != null &&
                  overdue!.salesTeamEmployeeName != null &&
                  overdue!.salesTeamEmployeeName!.isNotEmpty
              ? overdue!.salesTeamEmployeeName!
              : 'N/A',
        ),
        _buildDetailRow(
          'Order Date',
          DateFormater.formatDate(overdue!.orderDate.toString()),
        ),
        _buildDetailRow('Status', overdue!.statusName),
        _buildDetailRow(
          'Invoice Date',
          "${DateFormater.formatDate(overdue!.invoiceDateProcess.toString())}",
        ),
        _buildDetailRow('Invoice Number', overdue!.invoiceNumberProcess),
        _buildDetailRow(
          'Added By',
          '${overdue!.employeeName.toString()} ${overdue!.salesEmployeeName.toString()}',
        ),
        _buildDetailRow(
          'Invoice Generated By',
          '${overdue!.employeeName.toString()}${overdue!.salesEmployeeName.toString()}',
        ),
        _buildDetailRow('LR Number', overdue!.LrNumber),
        _buildDetailRow(
          'LR Date',
          "${DateFormater.formatDate(overdue!.LrDate.toString())}",
        ),
        overdue!.orderCopy != null && overdue!.orderCopy!.isNotEmpty
            ? _viewButton('Order Copy', () {
                try {
                  final filePath = overdue!.orderCopy.toString().toLowerCase();
                  final url = '${controller.url.value}${overdue!.orderCopy}';
                  if (filePath.endsWith('.pdf')) {
                    Get.toNamed(AppRoutes.viewpdf, arguments: url);
                  } else if (filePath.endsWith('.jpg') ||
                      filePath.endsWith('.png') ||
                      filePath.endsWith('.jpeg')) {
                    Get.toNamed(AppRoutes.viewImage, arguments: url);
                  }
                } catch (e) {
                  print('Error in viewButton: $e');
                }
              })
            : _buildDetailRow('Order Copy', '-'),
        overdue!.invoiceCopyNew != null && overdue!.invoiceCopyNew!.isNotEmpty
            ? _viewButton('Invoice Copy', () {
                try {
                  final filePath = overdue!.invoiceCopyNew
                      .toString()
                      .toLowerCase();
                  final url =
                      '${controller.url.value}${overdue!.invoiceCopyNew}';
                  if (filePath.endsWith('.pdf')) {
                    Get.toNamed(AppRoutes.viewpdf, arguments: url);
                  } else if (filePath.endsWith('.jpg') ||
                      filePath.endsWith('.png') ||
                      filePath.endsWith('.jpeg')) {
                    Get.toNamed(AppRoutes.viewImage, arguments: url);
                  }
                } catch (e) {
                  print('Error in viewButton: $e');
                }
              })
            : _buildDetailRow('Invoice Copy', '-'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Overdue Detail: ${srNo}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: ListView(children: _buildDetailsList()))],
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
