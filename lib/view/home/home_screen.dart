import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trailo/controller/dashborad/dashboard_controller.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/utility/nodatascreen.dart';
import 'package:trailo/view/sidebar/app_sidebar.dart';
import '../../controller/global_controller/company/company_controller.dart';
import '../../controller/global_controller/division/divsion_controller.dart';
import '../../controller/global_controller/transport/transport_controller.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';
import '../sidebar/app_sidebar_for_sales.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CompanyController companyController = Get.put(CompanyController());
  final DivsionController divisonController = Get.put(DivsionController());
  final DashboardController controller = Get.put(DashboardController());
  final TransportController transportController = Get.put(
    TransportController(),
  );

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<int> _getYears() {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => currentYear - index);
  }

  Future<void> _refreshData() async {
    await Future.wait([
      companyController.fetchCompany(context: context),
      transportController.fetchTransport(context: context),
      controller.refreshInwardList(context: context),
    ]);
  }

  void _showFilterBottomSheet() {
    String? tempSelectedCompanyId =
        controller.selectedCompanyId.value.isNotEmpty
        ? controller.selectedCompanyId.value
        : null;
    String? tempSelectedDivisionId =
        controller.selectedDivisionId.value.isNotEmpty
        ? controller.selectedDivisionId.value
        : null;
    String? tempSelectedTransportId =
        controller.selectedTransportId.value.isNotEmpty
        ? controller.selectedTransportId.value
        : null;
    String? tempSelectedMonth = controller.selectedMonth.value.isNotEmpty
        ? controller.selectedMonth.value
        : null;
    int? tempSelectedYear = controller.selectedYear.value != 0
        ? controller.selectedYear.value
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setBottomSheetState) {
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
                      'Filter',
                      style: TextStyle(
                        fontSize: 20,
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
                                tempSelectedDivisionId = null;
                                divisonController.divisionList.clear();
                                divisonController.fetchDivison(
                                  context: context,
                                  comapnyID: tempSelectedCompanyId,
                                );
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
                    Obx(
                      () => SizedBox(
                        height: 55,
                        child: DropdownSearch<String>(
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            showSelectedItems: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'Search Division',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          items: divisonController.getDivisionNames(),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Select Division',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              constraints: BoxConstraints.tightFor(height: 55),
                            ),
                            baseStyle: TextStyle(fontSize: 16),
                          ),
                          onChanged: (String? selectedDivisionName) {
                            if (selectedDivisionName != null) {
                              setBottomSheetState(() {
                                tempSelectedDivisionId = divisonController
                                    .getDivisionId(selectedDivisionName);
                              });
                            }
                          },
                          selectedItem: tempSelectedDivisionId != null
                              ? divisonController.getDivisionNameById(
                                  tempSelectedDivisionId!,
                                )
                              : null,
                          enabled: !divisonController.isLoading.value,
                          dropdownBuilder: (context, selectedItem) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                selectedItem ?? 'Select Division',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: divisonController.isLoading.value
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
                    Obx(
                      () => SizedBox(
                        height: 55,
                        child: DropdownSearch<String>(
                          popupProps: const PopupProps.menu(
                            showSearchBox: true,
                            showSelectedItems: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'Search Transport',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          items: transportController.getTransportNames(),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Select Transport',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              constraints: BoxConstraints.tightFor(height: 55),
                            ),
                            baseStyle: TextStyle(fontSize: 16),
                          ),
                          onChanged: (String? selectedTransportName) {
                            if (selectedTransportName != null) {
                              setBottomSheetState(() {
                                tempSelectedTransportId = transportController
                                    .getTransportId(selectedTransportName);
                              });
                            }
                          },
                          selectedItem: tempSelectedTransportId != null
                              ? transportController.getTransportNameById(
                                  tempSelectedTransportId!,
                                )
                              : null,
                          enabled: !transportController.isLoading.value,
                          dropdownBuilder: (context, selectedItem) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                selectedItem ?? 'Select Transport',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: transportController.isLoading.value
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
                    SizedBox(
                      height: 55,
                      child: DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: 'Search Month',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        items: _months,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Select Month',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            constraints: BoxConstraints.tightFor(height: 55),
                          ),
                          baseStyle: TextStyle(fontSize: 16),
                        ),
                        onChanged: (String? selectedMonth) {
                          setBottomSheetState(() {
                            tempSelectedMonth = selectedMonth;
                          });
                        },
                        selectedItem: tempSelectedMonth,
                        dropdownBuilder: (context, selectedItem) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              selectedItem ?? 'Select Month',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 55,
                      child: DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: 'Search Year',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        items: _getYears()
                            .map((year) => year.toString())
                            .toList(),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Select Year',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            constraints: BoxConstraints.tightFor(height: 55),
                          ),
                          baseStyle: TextStyle(fontSize: 16),
                        ),
                        onChanged: (String? selectedYear) {
                          setBottomSheetState(() {
                            tempSelectedYear = selectedYear != null
                                ? int.parse(selectedYear)
                                : null;
                          });
                        },
                        selectedItem: tempSelectedYear?.toString(),
                        dropdownBuilder: (context, selectedItem) {
                          return Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              selectedItem ?? 'Select Year',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              setBottomSheetState(() {
                                tempSelectedCompanyId = null;
                                tempSelectedDivisionId = null;
                                tempSelectedTransportId = null;
                                tempSelectedMonth = null;
                                tempSelectedYear = null;
                              });
                              controller.fetchInwardList(
                                context: context,
                                reset: true,
                                companyId: null,
                                divisionId: null,
                                transportId: null,
                                month: null,
                                year: null,
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Clear Filter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              controller.fetchInwardList(
                                context: context,
                                reset: true,
                                companyId: tempSelectedCompanyId,
                                divisionId: tempSelectedDivisionId,
                                transportId: tempSelectedTransportId,
                                month: tempSelectedMonth,
                                year: tempSelectedYear,
                              );
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    print("USER TYPE ${AppUtility.userType}");
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.filter_list),
          ),
        ],
        elevation: 2,
        backgroundColor: AppColors.primary,
      ),
      drawer: AppUtility.userType == "2" ? AppSidebarForSales() : AppSidebar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: AppUtility.userType == "1"
            ? AppUtility.hasPrivilege('dashboard')
                  ? _previlagesDash(screenWidth, screenHeight)
                  : Container()
            : AppUtility.userType == "2"
            ? _salesDash(screenWidth, screenHeight)
            : Container(),
      ),
    );
  }

  Widget _salesDash(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
          () => controller.isLoading.value
              ? _buildShimmerGrid(screenWidth)
              : controller.dashboard.isEmpty
              ? NoDataScreen()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Outward Analysis"),
                    Divider(),
                    SizedBox(height: screenHeight * 0.01),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.04,
                      mainAxisSpacing: screenWidth * 0.04,
                      childAspectRatio: 1.1,
                      children: [
                        // _buildGridItem(
                        //   'No of Invoices',
                        //   controller.dashboard.first.noOfInvoice,
                        //   () {},
                        //   const Color(0xFFfd7e14),
                        //   FontAwesomeIcons.fileInvoice,
                        // ),
                        _buildGridItem(
                          'No of Dispatches',
                          controller.dashboard.first.noOfDispatch,
                          () {},
                          const Color(0xFF6c757d),
                          FontAwesomeIcons.truck,
                        ),
                        _buildGridItem(
                          'No of Deliveries\nCompleted',
                          controller.dashboard.first.noOfCompleted,
                          () {},
                          const Color(0xFF664d03),
                          FontAwesomeIcons.solidCircleCheck,
                        ),
                        _buildGridItem(
                          'Pending Deliveries Overdue',
                          controller.dashboard.first.noOfPendingOverdue,
                          () {},
                          const Color(0xFF58151c),
                          FontAwesomeIcons.warning,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _previlagesDash(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
          () => controller.isLoading.value
              ? _buildShimmerGrid(screenWidth)
              : controller.dashboard.isEmpty
              ? NoDataScreen()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Outward Analysis"),
                    Divider(),
                    SizedBox(height: screenHeight * 0.01),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.04,
                      mainAxisSpacing: screenWidth * 0.04,
                      childAspectRatio: 1.1,
                      children: [
                        _buildGridItem(
                          'No of Invoices',
                          controller.dashboard.first.noOfInvoice,
                          () {},
                          const Color(0xFFfd7e14),
                          FontAwesomeIcons.fileInvoice,
                        ),
                        _buildGridItem(
                          'No of Dispatches',
                          controller.dashboard.first.noOfDispatch,
                          () {},
                          const Color(0xFF6c757d),
                          FontAwesomeIcons.truck,
                        ),
                        _buildGridItem(
                          'No of Deliveries\nCompleted',
                          controller.dashboard.first.noOfCompleted,
                          () {},
                          const Color(0xFF664d03),
                          FontAwesomeIcons.solidCircleCheck,
                        ),
                        _buildGridItem(
                          'Pending Deliveries Overdue',
                          controller.dashboard.first.noOfPendingOverdue,
                          () {},
                          const Color(0xFF58151c),
                          FontAwesomeIcons.warning,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _sectionTitle("Freight Analysis"),
                    Divider(),
                    SizedBox(height: screenHeight * 0.01),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.04,
                      mainAxisSpacing: screenWidth * 0.04,
                      childAspectRatio: 1.1,
                      children: [
                        _buildGridItem(
                          'Amount Freight 1',
                          controller
                                  .dashboard
                                  .first
                                  .sumOfFreightAmountOne
                                  .isEmpty
                              ? "0"
                              : controller.dashboard.first.sumOfFreightAmountOne
                                    .toString(),

                          () {},
                          const Color(0xFF055_db160),
                          FontAwesomeIcons.indianRupeeSign,
                        ),
                        _buildGridItem(
                          'Amount Freight 2',
                          controller
                                  .dashboard
                                  .first
                                  .sumOfFreightAmountTwo
                                  .isEmpty
                              ? "0"
                              : controller.dashboard.first.sumOfFreightAmountTwo
                                    .toString(),

                          () {},
                          Colors.red.shade400,
                          FontAwesomeIcons.solidCreditCard,
                        ),
                        _buildGridItem(
                          'Claim',
                          controller.dashboard.first.claim.toString(),
                          () {},
                          const Color(0xFF6a4a73),
                          FontAwesomeIcons.gavel,
                        ),
                        _buildGridItem(
                          'Unclaim',
                          controller.dashboard.first.unclaim.toString(),
                          () {},
                          const Color(0xFFBA884F),
                          FontAwesomeIcons.circleExclamation,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _sectionTitle("Critical Operation Analysis"),
                    Divider(),
                    SizedBox(height: screenHeight * 0.01),
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.04,
                      mainAxisSpacing: screenWidth * 0.04,
                      childAspectRatio: 1.1,
                      children: [
                        _buildGridItem(
                          'Delay In Invoicing',
                          controller.dashboard.first.delayInInvoicing
                              .toString(),
                          () {},
                          const Color(0xFF807e6b),
                          FontAwesomeIcons.solidHourglassHalf,
                        ),
                        _buildGridItem(
                          'Delay In Dispatch',
                          controller.dashboard.first.delayInDispatch.toString(),
                          () {},
                          const Color(0xFFcd74ac),
                          FontAwesomeIcons.solidClock,
                        ),
                        _buildGridItem(
                          'Delay In Delivery',
                          controller.dashboard.first.delayInDelivery.toString(),
                          () {},
                          const Color(0xFF4c7286),
                          FontAwesomeIcons.userSlash,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNoDataWidget(double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'No Data Available',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please apply Filter or refresh to load data.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.grey.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Text _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: AppColors.grey,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    );
  }

  Widget _buildShimmerGrid(double screenWidth) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: screenWidth * 0.04,
        mainAxisSpacing: screenWidth * 0.04,
        childAspectRatio: 1.1,
        children: List.generate(8, (index) => _buildShimmerItem()),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 32, height: 32, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 60, height: 28, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 100, height: 28, color: Colors.white),
        ],
      ),
    );
  }
}

Widget _buildGridItem(
  String title,
  String count,
  VoidCallback onTap,
  Color gradientColor,
  IconData icon,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColor.withOpacity(0.9),
            gradientColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.white.withOpacity(0.95)),
                const SizedBox(height: 8),
                Text(
                  count,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.95),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
