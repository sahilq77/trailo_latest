import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trailo/controller/inward/inward_list_controller.dart';
import 'package:trailo/utility/app_colors.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trailo/utility/date_formater.dart';
import '../../controller/global_controller/company/company_controller.dart';
import '../../utility/nodatascreen.dart';

class InwardListScreen extends StatefulWidget {
  const InwardListScreen({super.key});

  @override
  _InwardListScreenState createState() => _InwardListScreenState();
}

class _InwardListScreenState extends State<InwardListScreen> {
  final controller = Get.put(InwardListController());
  String? _selectedCompanyId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
  }

  void _showFilterBottomSheet() {
    String? tempSelectedCompanyId = _selectedCompanyId;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setBottomSheetState) {
            final CompanyController companyController = Get.put(
              CompanyController(),
            );
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Inwards',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => SizedBox(
                        height: 55,
                        child: DropdownSearch<String>(
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            showSelectedItems: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'Search Company',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          items: companyController.getCompanyNames(),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Select Company',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              constraints: BoxConstraints.tightFor(height: 55),
                            ),
                            baseStyle: TextStyle(fontSize: 16),
                          ),
                          onChanged: (String? selectedCompanyName) {
                            if (selectedCompanyName != null) {
                              setState(() {
                                tempSelectedCompanyId = companyController
                                    .getCompanyId(selectedCompanyName);
                              });
                            }
                          },
                          selectedItem: tempSelectedCompanyId != null
                              ? companyController.getCompanyNameById(
                                  tempSelectedCompanyId!,
                                )
                              : null,
                          enabled: !companyController.isLoading.value,
                          dropdownBuilder: (context, selectedItem) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                selectedItem ?? 'Select Company',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: companyController.isLoading.value
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempStartDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(), // Restrict future dates
                        );
                        if (picked != null) {
                          setBottomSheetState(() {
                            tempStartDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textfieldBorderColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: tempStartDate == null
                                  ? Colors.grey
                                  : Colors.black87,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tempStartDate == null
                                  ? 'Select Date'
                                  : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(tempStartDate!),
                              style: TextStyle(
                                fontSize: 14,
                                color: tempStartDate == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCompanyId = null;
                                _startDate = null;
                                _endDate = null;
                                controller.fetchInwardList(
                                  context: context,
                                  reset: true,
                                  companyId: null,
                                  startDate: null,
                                  endDate: null,
                                );
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Clear Filter'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCompanyId = tempSelectedCompanyId;
                                _startDate = tempStartDate;
                                _endDate = tempEndDate;
                                controller.fetchInwardList(
                                  context: context,
                                  reset: true,
                                  companyId: _selectedCompanyId,
                                  startDate: _startDate != null
                                      ? DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(_startDate!)
                                      : "",
                                );
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Apply Filter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case '1':
        return AppColors.primary;
      case '2':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF39373C),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ':  $value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF353B43),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 150, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Container(height: 14, width: 100, color: Colors.grey[300]),
                    const SizedBox(height: 6),
                    Container(height: 14, width: 80, color: Colors.grey[300]),
                    const SizedBox(height: 6),
                    Container(height: 14, width: 120, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Container(height: 20, width: 80, color: Colors.grey[300]),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.loadMoreResults(context: context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inward List'),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshInwardList(context: context),
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerPlaceholder();
          }

          if (controller.inwardList.isEmpty &&
              !controller.isLoadingMore.value) {
            return const NoDataScreen();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            itemCount:
                controller.inwardList.length +
                (controller.hasMoreData.value || controller.isLoadingMore.value
                    ? 1
                    : 0),
            itemBuilder: (context, int index) {
              if (index == controller.inwardList.length) {
                return controller.isLoadingMore.value
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'No more data',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.defaultblack,
                            ),
                          ),
                        ),
                      );
              }

              var inward = controller.inwardList[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.inwarddetail,
                    arguments: {
                      'inward': inward,
                      'srNo': index + 1, // Pass the serial number
                    },
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    // horizontal: 16,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border(
                        left: BorderSide(
                          color: _getStatusColor(inward.status),
                          width: 5,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildDetailRow(
                                  'Sr. No.',
                                  '${index + 1}',
                                ),
                              ),
                              if (inward.isVerified == "1")
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  transform: Matrix4.identity()..scale(1.0),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.success.withOpacity(0.9),
                                        AppColors.success.withOpacity(0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Verified",
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildDetailRow('Inward No.', inward.inwardNumber),
                          const SizedBox(height: 6),
                          _buildDetailRow('Company', inward.companyName),
                          const SizedBox(height: 6),
                          _buildDetailRow('Division', inward.divisionName),

                          const SizedBox(height: 6),
                          _buildDetailRow(
                            'Date',
                            DateFormater.formatDate(
                              inward.receiptDate.toString(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      inward.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getStatusColor(
                                        inward.status,
                                      ).withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    inward.statusName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(inward.status),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
