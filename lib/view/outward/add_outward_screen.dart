import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:trailo/controller/global_controller/sales_team/sales_team_employee_controller.dart';
import 'package:trailo/controller/inward/add_inward/check_invoice_number_controller.dart';
import '../../common/securetextinputformatter.dart';
import '../../controller/global_controller/customers/customer_controller.dart';

import '../../controller/global_controller/company/company_controller.dart';
import '../../controller/global_controller/division/divsion_controller.dart';
import '../../controller/global_controller/status/status_controller.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_utility.dart';
import '../../controller/outward/add_outward/add_outward_controller.dart';

class AddOutwardScreen extends StatefulWidget {
  const AddOutwardScreen({super.key});

  @override
  _AddOutwardScreenState createState() => _AddOutwardScreenState();
}

class _AddOutwardScreenState extends State<AddOutwardScreen> {
  final controller = Get.put(AddOutwardController());
  final checkInvcontroller = Get.put(CheckInvoiceNumberController());

  final CompanyController companyController = Get.put(CompanyController());
  final DivsionController divisonController = Get.put(DivsionController());
  final StatusController statusController = Get.put(StatusController());
  final CustomerController customerController = Get.put(CustomerController());
  final SalesTeamEmployeeController salesTeamEmployeeController = Get.put(
    SalesTeamEmployeeController(),
  );
  final _formKey = GlobalKey<FormState>();
  final outwardDateController = TextEditingController();
  final orderDateController = TextEditingController();
  final invoiceDateController = TextEditingController();
  final invoiceNumberController = TextEditingController();
  String? _companyID;
  String? _divisionID;
  String? _statusID;
  String? _customerID;
  String? _salesEmpID;
  String? _outwardDate, _orderDate, _invoiceDate, _invoiceNumber;
  String? _orderCopyPath, _invoiceCopyPath;

  @override
  void initState() {
    super.initState();
    companyController.fetchCompany(context: context);
  }

  final Map<String, String> _processTypes = {
    'Sales Order': '0',
    'Free Issue': '1',
    'Sample': '2',
    'Transfer': '3',
  };
  String? _processType;

  Future<void> _pickFile(bool isOrderCopy) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        if (isOrderCopy) {
          _orderCopyPath = result.files.single.name;
        } else {
          _invoiceCopyPath = result.files.single.name;
        }
      });
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isOutward,
    bool isOrder,
    bool isInvoice,
  ) async {
    DateTime? initialDate;
    DateTime? firstDate;
    DateTime lastDate;

    if (isInvoice && _orderDate != null) {
      // Parse the order date to set as the minimum date for invoice
      initialDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(_orderDate!);
      firstDate = initialDate; // Invoice date must be after order date
      lastDate = DateTime(2100); // Allow future dates for invoice
    } else {
      initialDate = DateTime.now();
      firstDate = DateTime(2000);
      lastDate = isOrder
          ? DateTime.now()
          : DateTime(2100); // Disable future dates for order
    }

    // Pick Date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate, // Use dynamic lastDate based on isOrder
    );

    if (pickedDate != null) {
      if (isOutward) {
        // Display date in dd-MM-yyyy for outwardDate, store in yyyy-MM-dd for API
        String displayDate = DateFormat('dd-MM-yyyy').format(pickedDate);
        String apiDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        setState(() {
          outwardDateController.text = displayDate;
          _outwardDate = apiDate;
        });
      } else if (isOrder || isInvoice) {
        // Date and time for orderDate and invoiceDate
        TimeOfDay? initialTime;
        if (isInvoice &&
            _orderDate != null &&
            pickedDate ==
                DateFormat('yyyy-MM-dd').parse(_orderDate!.substring(0, 10))) {
          // If invoice date is the same as order date, restrict time to after order time
          DateTime orderDateTime = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).parse(_orderDate!);
          initialTime = TimeOfDay(
            hour: orderDateTime.hour,
            minute: orderDateTime.minute,
          );
        } else {
          initialTime = TimeOfDay.now();
        }

        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: initialTime ?? TimeOfDay.now(),
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (pickedTime != null) {
          DateTime selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          String displayDateTime = DateFormat(
            'dd-MM-yyyy HH:mm:ss',
          ).format(selectedDateTime);
          String apiDateTime = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(selectedDateTime);

          if (isOrder) {
            // Ensure selected order date is not in the future
            if (selectedDateTime.isAfter(DateTime.now())) {
              Get.snackbar(
                'Error',
                'Order date and time cannot be in the future.',
                backgroundColor: AppColors.error,
                colorText: Colors.white,
              );
              return;
            }
            setState(() {
              orderDateController.text = displayDateTime;
              _orderDate = apiDateTime;
              // Clear invoice date if it exists and is earlier than or equal to the new order date
              if (_invoiceDate != null) {
                DateTime invoiceDate = DateFormat(
                  'yyyy-MM-dd HH:mm:ss',
                ).parse(_invoiceDate!);
                if (invoiceDate.isBefore(selectedDateTime) ||
                    invoiceDate.isAtSameMomentAs(selectedDateTime)) {
                  invoiceDateController.clear();
                  _invoiceDate = null;
                  Get.snackbar(
                    'Warning',
                    'Invoice date was cleared as it was earlier than or equal to the new order date.',
                    backgroundColor: AppColors.secondary,
                    colorText: Colors.white,
                  );
                }
              }
            });
          } else if (isInvoice) {
            // Validate that invoice date and time is after order date and time
            if (_orderDate != null) {
              DateTime orderDate = DateFormat(
                'yyyy-MM-dd HH:mm:ss',
              ).parse(_orderDate!);
              if (selectedDateTime.isBefore(orderDate) ||
                  selectedDateTime.isAtSameMomentAs(orderDate)) {
                Get.snackbar(
                  'Error',
                  'Invoice date and time must be after the order date and time.',
                  backgroundColor: AppColors.error,
                  colorText: Colors.white,
                );
                return;
              }
            }
            setState(() {
              invoiceDateController.text = displayDateTime;
              _invoiceDate = apiDateTime;
            });
          }
        }
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_processType == null) {
        Get.snackbar(
          'Error',
          'Please select a Process Type',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return;
      }

      // Additional validation for invoice date and time
      if (_orderDate != null && _invoiceDate != null) {
        DateTime orderDate = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).parse(_orderDate!);
        DateTime invoiceDate = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).parse(_invoiceDate!);
        if (invoiceDate.isBefore(orderDate) ||
            invoiceDate.isAtSameMomentAs(orderDate)) {
          Get.snackbar(
            'Error',
            'Invoice date and time must be after the order date and time.',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
          return;
        }
      }

      final data = <String, String>{
        'employee_id': AppUtility.userID?.toString() ?? '',
        'user_type': AppUtility.userType?.toString() ?? '',
        'company_id': _companyID ?? '',
        'division_id': _divisionID ?? '',
        'customer_id': _customerID ?? '',
        'process_type': _processType ?? '',
        'status_id': _statusID ?? '',
        'sales_team_employee_id': _salesEmpID ?? '',
        'outword_date': _outwardDate ?? '',
        'order_date': _orderDate ?? '',
        'invoice_date_process': _invoiceDate ?? '',
        'invoice_number_process': invoiceNumberController.text,
        'order_copy': controller.orderCopyFile.value?.name ?? '',
        'invoice_copy_new': controller.invoiceCopyFile.value?.name ?? '',
        'outward_id': '',
      };
      controller.submitOutwardData(context: context, data: data).then((
        success,
      ) {
        if (success) {
          _clearForm();
        }
      });
    }
  }

  void _clearForm() {
    setState(() {
      outwardDateController.clear();
      orderDateController.clear();
      invoiceDateController.clear();
      invoiceNumberController.clear();
      _companyID = null;
      _divisionID = null;
      _statusID = null;
      _customerID = null;
      _salesEmpID = null;
      _outwardDate = null;
      _orderDate = null;
      _invoiceDate = null;
      _invoiceNumber = null;
      _orderCopyPath = null;
      _invoiceCopyPath = null;
      _processType = null;
      companyController.selectedCompanyVal?.value = '';
      divisonController.selectedDivisionVal?.value = '';
      statusController.selectedStatusVal?.value = '';
      customerController.selectedCustomerVal?.value = '';
      salesTeamEmployeeController.selectedEmployeeVal?.value = '';
      checkInvcontroller.flag.value = "";
      controller.orderCopyFile.value = null;
      controller.invoiceCopyFile.value = null;
      divisonController.divisionList.clear();
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    print("User Type==> ${AppUtility.userType}");
    return WillPopScope(
      onWillPop: () async {
        _clearForm(); // Clear form data before navigating back
        return true; // Allow navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Outward'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _clearForm(); // Clear form data when app bar back button is pressed
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUnfocus,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectiontitle("Outward Details"),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    controller: outwardDateController,
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          text: 'Outward Date ',
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                      hintText: 'Select Date',
                    ),
                    onTap: () => _selectDate(context, true, false, false),
                    validator: (value) =>
                        _outwardDate == null ? 'Please Select Date' : null,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Obx(
                    () => DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Search Company',
                          ),
                        ),
                      ),
                      items: companyController.getCompanyNames(),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Select Company ',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        baseStyle: TextStyle(fontSize: 16),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please Select Company'
                          : null,
                      onChanged: (String? selectedCompanyName) async {
                        if (selectedCompanyName != null) {
                          companyController.selectedCompanyVal?.value =
                              selectedCompanyName;
                          final companyId = companyController.getCompanyId(
                            selectedCompanyName,
                          );
                          setState(() {
                            _companyID = companyId;
                            _divisionID = null;
                            divisonController.selectedDivisionVal?.value = '';
                          });
                          divisonController.divisionList
                              .clear(); // Clear division list
                          if (companyId != null && companyId.isNotEmpty) {
                            await divisonController.fetchDivison(
                              context: context,
                              comapnyID: companyId,
                              forceFetch: true,
                            );
                          } else {
                            divisonController.divisionList.clear();
                            divisonController.selectedDivisionVal?.value = '';
                            Get.snackbar(
                              'Error',
                              'Invalid company selected',
                              backgroundColor: AppColors.error,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },
                      selectedItem: null,
                      enabled: !companyController.isLoading.value,
                      dropdownBuilder: (context, selectedItem) => Container(
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
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Obx(
                    () => DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Search Division',
                          ),
                        ),
                      ),
                      items: divisonController.getDivisionNames(),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please Select Division'
                          : null,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Select Division ',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        baseStyle: TextStyle(fontSize: 16),
                      ),
                      onChanged: (String? selectedDivisionName) {
                        if (selectedDivisionName != null) {
                          divisonController.selectedDivisionVal?.value =
                              selectedDivisionName;
                          setState(() {
                            _divisionID = divisonController.getDivisionId(
                              selectedDivisionName,
                            );
                          });
                        } else {
                          divisonController.selectedDivisionVal?.value = '';
                          setState(() {
                            _divisionID = null;
                          });
                        }
                      },
                      selectedItem:
                          divisonController
                                  .selectedDivisionVal
                                  ?.value
                                  .isEmpty ??
                              true
                          ? null
                          : divisonController.selectedDivisionVal?.value,
                      enabled: !divisonController.isLoading.value,
                      dropdownBuilder: (context, selectedItem) => Container(
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
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      showSelectedItems: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Search Process Type',
                        ),
                      ),
                    ),
                    items: _processTypes.keys.toList(),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Process Type ',
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      baseStyle: TextStyle(fontSize: 16),
                    ),
                    selectedItem: _processType != null
                        ? _processTypes.keys.firstWhere(
                            (key) => _processTypes[key] == _processType,
                            orElse: () => 'Sales Order',
                          )
                        : null,
                    validator: (value) =>
                        value == null ? 'Please Select Process Type' : null,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _processType = _processTypes[newValue];
                          _salesEmpID = null;
                          _customerID = null;
                          salesTeamEmployeeController
                                  .selectedEmployeeVal
                                  .value =
                              '';
                          customerController.selectedCustomerVal.value = '';
                        });
                      }
                    },
                    dropdownBuilder: (context, selectedItem) => Text(
                      selectedItem ?? 'Select a Process Type',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Obx(
                    () =>
                        customerController.isLoading.value ||
                            salesTeamEmployeeController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : _processType == "2"
                        ? DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: 'Search Employee',
                                ),
                              ),
                            ),
                            items: salesTeamEmployeeController
                                .getEmployeeNames(),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                label: RichText(
                                  text: TextSpan(
                                    text: 'Issue Name(Sales Team Employee) ',
                                    style: TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              baseStyle: TextStyle(fontSize: 16),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please Select Sales'
                                : null,
                            onChanged: (String? selectedSalesEmployeeName) {
                              if (selectedSalesEmployeeName != null) {
                                salesTeamEmployeeController
                                        .selectedEmployeeVal
                                        .value =
                                    selectedSalesEmployeeName;
                                setState(() {
                                  _salesEmpID = salesTeamEmployeeController
                                      .getEmployeeId(selectedSalesEmployeeName);
                                  print("Sales Employee ID set: $_salesEmpID");
                                });
                              }
                            },
                            selectedItem:
                                salesTeamEmployeeController
                                    .selectedEmployeeVal
                                    .value
                                    .isNotEmpty
                                ? salesTeamEmployeeController
                                      .selectedEmployeeVal
                                      .value
                                : null,
                            enabled:
                                !salesTeamEmployeeController.isLoading.value,
                            dropdownBuilder: (context, selectedItem) => Text(
                              selectedItem ?? 'Select Issue Name',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    salesTeamEmployeeController.isLoading.value
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          )
                        : DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: 'Search Customer',
                                ),
                              ),
                            ),
                            items: customerController.getCustomerNames(),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                label: RichText(
                                  text: TextSpan(
                                    text: 'Select Customer ',
                                    style: TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              baseStyle: TextStyle(fontSize: 16),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please Select Customer'
                                : null,
                            onChanged: (String? selectedCustomerName) {
                              if (selectedCustomerName != null) {
                                customerController.selectedCustomerVal.value =
                                    selectedCustomerName;
                                setState(() {
                                  _customerID = customerController
                                      .getCustomerId(selectedCustomerName);
                                  print("Customer ID set: $_customerID");
                                });
                              }
                            },
                            selectedItem:
                                customerController
                                    .selectedCustomerVal
                                    .value
                                    .isNotEmpty
                                ? customerController.selectedCustomerVal.value
                                : null,
                            enabled: !customerController.isLoading.value,
                            dropdownBuilder: (context, selectedItem) => Text(
                              selectedItem ?? 'Select a Customer',
                              style: TextStyle(
                                fontSize: 16,
                                color: customerController.isLoading.value
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    readOnly: true,
                    controller: orderDateController,
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          text: 'Order Date ',
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                      hintText: 'DD-MM-YYYY HH:MM:SS',
                    ),
                    onTap: () => _selectDate(context, false, true, false),
                    validator: (value) => _orderDate == null
                        ? 'Please select order date & time'
                        : null,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Obx(
                    () => DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Search Status',
                          ),
                        ),
                      ),
                      items: statusController.getStatusNames(),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Select Status ',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        baseStyle: TextStyle(fontSize: 16),
                      ),
                      onChanged: (String? selectedStatusName) {
                        if (selectedStatusName != null) {
                          statusController.selectedStatusVal?.value =
                              selectedStatusName;
                          setState(() {
                            _statusID = statusController.getStatusId(
                              selectedStatusName,
                            );
                          });
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Please Select Status' : null,
                      selectedItem: null,
                      enabled: !statusController.isLoading.value,
                      dropdownBuilder: (context, selectedItem) => Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selectedItem ?? 'Select Status',
                          style: TextStyle(
                            fontSize: 16,
                            color: statusController.isLoading.value
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    readOnly: true,
                    controller: invoiceDateController,
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          text: 'Invoice Date ',
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: _orderDate == null ? '' : '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      suffixIcon: _orderDate == null
                          ? null
                          : const Icon(Icons.calendar_today),
                      hintText: 'DD-MM-YYYY HH:MM:SS',
                      enabled:
                          _orderDate !=
                          null, // Enable only if order date is selected
                    ),
                    onTap: _orderDate == null
                        ? null
                        : () => _selectDate(context, false, false, true),
                    validator: (value) {
                      if (_orderDate != null &&
                          (value == null || value.isEmpty)) {
                        return 'Please select invoice date & time';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  TextFormField(
                    controller: invoiceNumberController,
                    inputFormatters: [SecureTextInputFormatter.deny()],
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          text: 'Invoice Number ',
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onChanged: (value) async {
                      await checkInvcontroller.verifyInvoiceNumber(
                        invNo: value,
                        outwardID: "",
                        context: context,
                      );
                    },
                    onSaved: (value) async {
                      await checkInvcontroller.verifyInvoiceNumber(
                        invNo: value!,
                        outwardID: "",
                        context: context,
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter an Invoice Number';
                      } else if (checkInvcontroller.flag == "1") {
                        return 'Invoice Number Already Exists';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _sectiontitle('Document Upload'),
                  SizedBox(height: screenHeight * 0.02),
                  _buildFilePicker("Order Copy", "order_copy"),
                  SizedBox(height: screenHeight * 0.01),
                  _buildFilePicker("Invoice Copy", "invoice_copy_new"),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _submitForm();
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePicker(String label, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Obx(
          () => ListTile(
            title: Text(
              controller.getFileName(field) ?? 'No file selected',
              style: TextStyle(
                color: controller.getFileName(field) != null
                    ? Colors.black
                    : Colors.grey,
              ),
            ),
            trailing: const Icon(Icons.attach_file),
            onTap: () => controller.pickFile(field),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _sectiontitle(String title) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
