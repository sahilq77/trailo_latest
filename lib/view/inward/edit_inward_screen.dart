import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trailo/controller/inward/add_inward/add_inward_controller.dart';
import 'package:trailo/controller/global_controller/company/company_controller.dart';
import 'package:trailo/controller/global_controller/division/divsion_controller.dart';
import 'package:trailo/controller/global_controller/transport/transport_controller.dart';
import 'package:trailo/controller/global_controller/status/status_controller.dart';
import 'package:trailo/controller/global_controller/vendor/vendor_controller.dart';
import 'package:trailo/controller/global_controller/customers/customer_controller.dart';
import 'package:trailo/controller/inward/add_inward/check_debit_note_number_controller.dart'
    show CheckDebitNoteNumberController;
import 'package:trailo/utility/app_utility.dart';
import 'package:trailo/utility/app_colors.dart';
import '../../common/securetextinputformatter.dart';
import '../../controller/inward/add_inward/check_invoice_number_controller.dart';
import '../../controller/inward/add_inward/check_inward_number_controller.dart';
import '../../controller/inward/add_inward/check_vendor_invoice_number_controller.dart';
import '../../controller/inward/inward_list_controller.dart';
import '../../model/inward_list/get_inward_list_response.dart';
import '../../utility/app_routes.dart';

class EditInwardScreen extends StatefulWidget {
  const EditInwardScreen({super.key});

  @override
  _EditInwardScreenState createState() => _EditInwardScreenState();
}

class _EditInwardScreenState extends State<EditInwardScreen> {
  final controller = Get.put(AddInwardController());
  final inwardListController = Get.put(InwardListController());

  final checkVennderInvoiceController = Get.put(
    CheckVendorInvoiceNumberController(),
  );
  final checkDebitNoteNumberController = Get.put(
    CheckDebitNoteNumberController(),
  );
  final checkInwardController = Get.put(CheckInwardNumberController());
  final CompanyController companyController = Get.put(CompanyController());
  final DivsionController divisonController = Get.put(DivsionController());
  final TransportController transportController = Get.put(
    TransportController(),
  );
  final StatusController statusController = Get.put(StatusController());
  final VendorController vendorController = Get.put(VendorController());
  final CustomerController customerController = Get.put(CustomerController());
  final _formKey = GlobalKey<FormState>();
  final receiptDateController = TextEditingController();
  final inwardNumberController = TextEditingController();
  final debitNoteController = TextEditingController();
  final debitNoteDateController = TextEditingController();
  final invoiceNumberController = TextEditingController();
  final invoiceDateController = TextEditingController();
  final lrController = TextEditingController();
  final lrDateController = TextEditingController();
  final freightAmtController = TextEditingController();
  String? _dateOfReceipt;
  String? _companyID;
  String? _divisionID;
  String? _customerVendorType = '1';
  String? _claimType = '1';
  String? _customerID;
  String? _vendorID;
  String? _debitNoteDate;
  String? _invoiceDate;
  String? _lrDate;
  String? _statusID;
  String? _transportID;
  String? _customerVendorError;
  String? _claimTypeError;
  InwardListData? inwardid;
  int? srNo;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      setState(() {
        inwardid = arguments['inward'] as InwardListData?;
        srNo = arguments['srNo'] as int?;
      });
    }
    _loadData();
  }

  Future<void> _loadData() async {
    if (inwardid == null) {
      Get.snackbar(
        'Error',
        'No inward data provided',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Set text fields with null checks
      receiptDateController.text = inwardid!.receiptDate != null
          ? DateFormat('dd-MM-yyyy').format(inwardid!.receiptDate!)
          : '';
      inwardNumberController.text = inwardid!.inwardNumber ?? '';
      invoiceNumberController.text = inwardid!.vendorInvoiceNumber ?? '';
      debitNoteController.text = inwardid!.debitNoteNumber ?? '';
      lrController.text = inwardid!.lrNumber ?? '';
      freightAmtController.text = inwardid!.freightAmount?.toString() ?? '';

      // Set date fields with null checks
      _dateOfReceipt = inwardid!.receiptDate != null
          ? DateFormat('yyyy-MM-dd').format(inwardid!.receiptDate!)
          : null;
      invoiceDateController.text = inwardid!.vendorInvoiceDate != null
          ? DateFormat('dd-MM-yyyy').format(inwardid!.vendorInvoiceDate!)
          : '';
      _invoiceDate = inwardid!.vendorInvoiceDate != null
          ? DateFormat('yyyy-MM-dd').format(inwardid!.vendorInvoiceDate!)
          : null;
      debitNoteDateController.text = inwardid!.debitNoteDate != null
          ? DateFormat('dd-MM-yyyy').format(inwardid!.debitNoteDate!)
          : '';
      _debitNoteDate = inwardid!.debitNoteDate != null
          ? DateFormat('yyyy-MM-dd').format(inwardid!.debitNoteDate!)
          : null;
      lrDateController.text = inwardid!.lrDate != null
          ? DateFormat('dd-MM-yyyy').format(inwardid!.lrDate!)
          : '';
      _lrDate = inwardid!.lrDate != null
          ? DateFormat('yyyy-MM-dd').format(inwardid!.lrDate!)
          : null;

      // Set IDs with null checks
      _companyID = inwardid!.companyId;
      _divisionID = inwardid!.divisionId;
      _statusID = inwardid!.statusId;
      _customerID = inwardid!.customerId;
      _vendorID = inwardid!.vendorId;
      _transportID = inwardid!.transportId;
      _customerVendorType = inwardid!.entityType ?? '1';
      _claimType = inwardid!.claim ?? '1';

      // Initialize controller values if null
      companyController.selectedCompanyVal ??= ''.obs;
      statusController.selectedStatusVal ??= ''.obs;
      divisonController.selectedDivisionVal ??= ''.obs;
      customerController.selectedCustomerVal ??= ''.obs;
      vendorController.selectedVendorVal ??= ''.obs;
      transportController.selectedTransportVal ??= ''.obs;

      // Fetch and set company data
      await companyController.fetchCompany(context: context);
      if (_companyID != null && _companyID!.isNotEmpty) {
        String? companyName = companyController.getCompanyNameById(_companyID!);
        companyController.selectedCompanyVal!.value =
            companyName?.isNotEmpty == true ? companyName! : '';
      } else {
        companyController.selectedCompanyVal!.value = '';
      }

      // Fetch and set division data
      if (_companyID != null && _companyID!.isNotEmpty) {
        await divisonController.fetchDivison(
          context: context,
          comapnyID: _companyID!,
          forceFetch: true,
        );
        String? divisionName = _divisionID != null
            ? divisonController.getDivisionNameById(_divisionID!)
            : null;
        divisonController.selectedDivisionVal!.value =
            divisionName?.isNotEmpty == true ? divisionName! : '';
      } else {
        divisonController.divisionList.clear();
        divisonController.selectedDivisionVal!.value = '';
      }

      // Fetch and set status data
      await statusController.fetchStatus(context: context);
      if (_statusID != null && _statusID!.isNotEmpty) {
        String? statusName = statusController.getStatusNameById(_statusID!);
        statusController.selectedStatusVal!.value =
            statusName?.isNotEmpty == true ? statusName! : '';
      } else {
        statusController.selectedStatusVal!.value = '';
      }

      // Fetch and set customer or vendor data
      if (_customerVendorType == '1' &&
          _customerID != null &&
          _customerID!.isNotEmpty) {
        await customerController.fetchCustomers(context: context);
        String? customerName = customerController.getCustomerNameById(
          _customerID!,
        );
        customerController.selectedCustomerVal!.value =
            customerName?.isNotEmpty == true ? customerName! : '';
      } else if (_customerVendorType == '0' &&
          _vendorID != null &&
          _vendorID!.isNotEmpty) {
        await vendorController.fetchVendors(context: context);
        String? vendorName = vendorController.getVendorNameById(_vendorID!);
        vendorController.selectedVendorVal!.value =
            vendorName?.isNotEmpty == true ? vendorName! : '';
      } else {
        customerController.selectedCustomerVal!.value = '';
        vendorController.selectedVendorVal!.value = '';
      }

      // Fetch and set transport data
      await transportController.fetchTransport(context: context);
      if (_transportID != null && _transportID!.isNotEmpty) {
        String? transportName = transportController.getTransportNameById(
          _transportID!,
        );
        transportController.selectedTransportVal!.value =
            transportName?.isNotEmpty == true ? transportName! : '';
      } else {
        transportController.selectedTransportVal!.value = '';
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      print('Error loading data: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load inward data: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _selectReceiptDate(
    BuildContext context,
    TextEditingController controller,
    Function(String?) setter,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2036), // Restrict future dates
    );
    if (picked != null && mounted) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
        setter(DateFormat('yyyy-MM-dd').format(picked));
      });
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    Function(String?) setter,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
        setter(DateFormat('yyyy-MM-dd').format(picked));
      });
    }
  }

  void _submitForm() {
    setState(() {
      _customerVendorError = _customerVendorType == null
          ? 'Please select Customer or Vendor'
          : null;
      _claimTypeError = _claimType == null
          ? 'Please select Claim option'
          : null;
    });

    if (_formKey.currentState!.validate() &&
        _customerVendorError == null &&
        _claimTypeError == null) {
      final data = {
        'employee_id': AppUtility.userID.toString(),
        'user_type': AppUtility.userType.toString(),
        'company_id': _companyID ?? '',
        'division_id': _divisionID ?? '',
        'customer_id': _customerID ?? '',
        'vendor_id': _vendorID ?? '',
        'status_id': _statusID ?? '',
        'transport_id': _transportID ?? '',
        'receipt_date': _dateOfReceipt ?? '',
        'inward_number': inwardNumberController.text,
        'entity_type': _customerVendorType ?? '',
        'debit_note_number': _customerVendorType == "1"
            ? debitNoteController.text
            : '',
        'debit_note_date': _customerVendorType == "1"
            ? (_debitNoteDate ?? '')
            : '',
        'vendor_invoice_number': _customerVendorType == "0"
            ? invoiceNumberController.text
            : '',
        'vendor_invoice_date': _customerVendorType == "0"
            ? (_invoiceDate ?? '')
            : '',
        'lr_number': lrController.text,
        'lr_date': _lrDate ?? '',
        'freight_amount': freightAmtController.text,
        'claim': _claimType ?? '',
        'lr_copy': controller.lrCopyFile.value?.name ?? '',
        'debit_note_copy': _customerVendorType == "1"
            ? controller.debitNoteCopyFile.value?.name ?? ''
            : '',
        'invoice_copy': _customerVendorType == "1"
            ? controller.invoiceCopyFile.value?.name ?? ''
            : controller.invoiceCopyFile.value?.name ?? '',
        'inward_id': inwardid!.id ?? '',
      };

      controller
          .submitInwardData(data: data, context: context, id: inwardid!.id)
          .then((success) {
            // Handle success if needed
          });
    }
  }

  void _clearForm() {
    if (mounted) {
      setState(() {
        _dateOfReceipt = null;
        _companyID = null;
        _divisionID = null;
        _customerVendorType = '1';
        _claimType = '1';
        _customerID = null;
        _vendorID = null;
        _debitNoteDate = null;
        _invoiceDate = null;
        _lrDate = null;
        _statusID = null;
        _transportID = null;
        _customerVendorError = null;
        _claimTypeError = null;

        receiptDateController.clear();
        inwardNumberController.clear();
        debitNoteController.clear();
        debitNoteDateController.clear();
        invoiceNumberController.clear();
        invoiceDateController.clear();
        lrController.clear();
        lrDateController.clear();
        freightAmtController.clear();

        companyController.selectedCompanyVal?.value = '';
        divisonController.selectedDivisionVal?.value = '';
        customerController.selectedCustomerVal?.value = '';
        vendorController.selectedVendorVal?.value = '';
        transportController.selectedTransportVal?.value = '';
        statusController.selectedStatusVal?.value = '';
        controller.lrCopyFile.value = null;
        controller.debitNoteCopyFile.value = null;
        controller.invoiceCopyFile.value = null;
        divisonController.divisionList.clear();
        checkVennderInvoiceController.flag.value = "";
        checkInwardController.flag.value = "";
        checkDebitNoteNumberController.flag.value = "";

        _formKey.currentState?.reset();
      });
    }
  }

  @override
  void dispose() {
    receiptDateController.dispose();
    inwardNumberController.dispose();
    debitNoteController.dispose();
    debitNoteDateController.dispose();
    invoiceNumberController.dispose();
    invoiceDateController.dispose();
    lrController.dispose();
    lrDateController.dispose();
    freightAmtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (mounted) {
          _clearForm();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Inward"),
          backgroundColor: AppColors.primary,
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.cancel),
          //     onPressed: _clearForm,
          //     tooltip: 'Cancel',
          //   ),
          // ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Inward Details"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: receiptDateController,
                          decoration: InputDecoration(
                            label: RichText(
                              text: TextSpan(
                                text: 'Date Of Receipt ',
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectReceiptDate(
                                // Use new function
                                context,
                                receiptDateController,
                                (value) => _dateOfReceipt = value,
                              ),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please Select Date'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: inwardNumberController,
                          inputFormatters: [SecureTextInputFormatter.deny()],
                          decoration: InputDecoration(
                            label: RichText(
                              text: TextSpan(
                                text: 'Inward No. ',
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            suffixIcon: Icon(Icons.edit),
                          ),
                          onChanged: (value) {
                            // print("flag ${checkInwardController.flag}");
                            // checkInwardController.verifyInwardNumber(
                            //   inwardNo: value,
                            //   inwardID: inwardid!.id,
                            //   context: context,
                            // );
                          },

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Inward Number';
                            }
                            //  else if (checkInwardController.flag.value ==
                            //     "1") {
                            //   return 'Inward Number Already Exists';
                            // }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Search Company',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      items: companyController.getCompanyNames(),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: RichText(
                            text: const TextSpan(
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
                          border: OutlineInputBorder(),
                        ),
                        baseStyle: const TextStyle(fontSize: 16),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please Select Company'
                          : null,
                      onChanged: (String? selectedCompanyName) async {
                        if (selectedCompanyName != null) {
                          companyController.selectedCompanyVal!.value =
                              selectedCompanyName;
                          final companyId = companyController.getCompanyId(
                            selectedCompanyName,
                          );
                          setState(() {
                            _companyID = companyId;
                            _divisionID = null;
                            divisonController.selectedDivisionVal!.value = '';
                          });
                          divisonController.divisionList.clear();
                          if (companyId != null && companyId.isNotEmpty) {
                            await divisonController.fetchDivison(
                              context: context,
                              comapnyID: companyId,
                              forceFetch: true,
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              'Invalid company selected',
                              backgroundColor: AppColors.error,
                              colorText: Colors.white,
                            );
                          }
                        } else {
                          companyController.selectedCompanyVal!.value = '';
                          setState(() {
                            _companyID = null;
                          });
                        }
                      },
                      selectedItem:
                          companyController.selectedCompanyVal!.value.isNotEmpty
                          ? companyController.selectedCompanyVal!.value
                          : null,
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
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownSearch<String>(
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
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please Select Division'
                          : null,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: RichText(
                            text: const TextSpan(
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
                          border: OutlineInputBorder(),
                        ),
                        baseStyle: const TextStyle(fontSize: 16),
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
                              .selectedDivisionVal!
                              .value
                              .isNotEmpty
                          ? divisonController.selectedDivisionVal?.value
                          : null,
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
                  const SizedBox(height: 20),
                  _sectionTitle("Customer/Vendor Name *"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: '1',
                            groupValue: _customerVendorType,
                            activeColor: Colors.grey,
                            onChanged: null,
                          ),
                          const Text('Customer'),
                          Radio(
                            value: '0',
                            groupValue: _customerVendorType,
                            activeColor: Colors.grey,
                            onChanged: null,
                          ),
                          const Text('Vendor'),
                        ],
                      ),
                      if (_customerVendorError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Text(
                            _customerVendorError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => _customerVendorType == "1"
                        ? DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: 'Search Customer',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            items: customerController.getCustomerNames(),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                label: RichText(
                                  text: const TextSpan(
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
                                border: OutlineInputBorder(),
                              ),
                              baseStyle: const TextStyle(fontSize: 16),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please Select Customer'
                                : null,
                            onChanged: (String? selectedCustomerName) {
                              if (selectedCustomerName != null && mounted) {
                                customerController.selectedCustomerVal?.value =
                                    selectedCustomerName;
                                setState(() {
                                  _customerID = customerController
                                      .getCustomerId(selectedCustomerName);
                                  _vendorID = null;
                                  vendorController.selectedVendorVal?.value =
                                      '';
                                });
                              }
                            },
                            selectedItem:
                                customerController
                                    .selectedCustomerVal!
                                    .value
                                    .isNotEmpty
                                ? customerController.selectedCustomerVal?.value
                                : null,
                            enabled: !customerController.isLoading.value,
                            dropdownBuilder: (context, selectedItem) =>
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    selectedItem ?? 'Select Customer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: customerController.isLoading.value
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                          )
                        : DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              showSelectedItems: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: 'Search Vendor',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            items: vendorController.getVendorNames(),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                label: RichText(
                                  text: const TextSpan(
                                    text: 'Select Vendor ',
                                    style: TextStyle(color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              baseStyle: const TextStyle(fontSize: 16),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please Select Vendor'
                                : null,
                            onChanged: (String? selectedVendorName) {
                              if (selectedVendorName != null && mounted) {
                                vendorController.selectedVendorVal?.value =
                                    selectedVendorName;
                                setState(() {
                                  _vendorID = vendorController.getVendorId(
                                    selectedVendorName,
                                  );
                                  _customerID = null;
                                  customerController
                                          .selectedCustomerVal
                                          ?.value =
                                      '';
                                });
                              }
                            },
                            selectedItem:
                                vendorController
                                    .selectedVendorVal!
                                    .value
                                    .isNotEmpty
                                ? vendorController.selectedVendorVal?.value
                                : null,
                            enabled: !vendorController.isLoading.value,
                            dropdownBuilder: (context, selectedItem) =>
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    selectedItem ?? 'Select Vendor',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: vendorController.isLoading.value
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                          ),
                  ),
                  const SizedBox(height: 10),
                  if (_customerVendorType == "1") ...[
                    TextFormField(
                      controller: debitNoteController,
                      inputFormatters: [SecureTextInputFormatter.deny()],
                      decoration: InputDecoration(
                        labelText: 'Debit Note Number',
                      ),
                      onChanged: (value) async {
                        // await checkDebitNoteNumberController
                        //     .verifyInvoiceNumber(
                        //       invNo: value,
                        //       inwardID: inwardid!.id,
                        //       context: context,
                        //     );
                      },
                      onSaved: (value) async {
                        // await checkDebitNoteNumberController
                        //     .verifyInvoiceNumber(
                        //       invNo: value!,
                        //       inwardID: "",
                        //       context: context,
                        //     );
                      },
                      validator: (value) {
                        // if (checkDebitNoteNumberController.flag == "1") {
                        //   return 'Debit Note Number Already Exists';
                        // }
                        // return null;
                      },
                    ),
                  ] else ...[
                    TextFormField(
                      controller: invoiceNumberController,
                      inputFormatters: [SecureTextInputFormatter.deny()],
                      decoration: InputDecoration(
                        labelText: "Invoice Number ",
                        // label: RichText(
                        //   text: TextSpan(
                        //     text: 'Invoice Number ',
                        //     style: TextStyle(color: Colors.black),
                        //     children: [
                        //       // TextSpan(
                        //       //   text: '*',
                        //       //   style: TextStyle(color: Colors.red),
                        //       // ),
                        //     ],
                        //   ),
                        // ),
                      ),
                      onChanged: (value) async {
                        // await checkVennderInvoiceController.verifyInvoiceNumber(
                        //   invNo: value,
                        //   inwardID: "",
                        //   context: context,
                        // );
                      },
                      onSaved: (value) async {
                        // await checkVennderInvoiceController.verifyInvoiceNumber(
                        //   invNo: value!,
                        //   inwardID: inwardid!.id,
                        //   context: context,
                        // );
                      },
                      validator: (value) {
                        // if (checkVennderInvoiceController.flag == "1") {
                        //   return 'Invoice Number Already Exists';
                        // }
                        // return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      onTap: () => _selectDate(
                        context,
                        invoiceDateController,
                        (value) => _invoiceDate = value,
                      ),
                      controller: invoiceDateController,
                      decoration: InputDecoration(
                        labelText: "Invoice Date",
                        // label: RichText(
                        //   text: TextSpan(
                        //     text: 'Invoice Date ',
                        //     style: TextStyle(color: Colors.black),
                        //     children: [
                        //       // TextSpan(
                        //       //   text: '*',
                        //       //   style: TextStyle(color: Colors.red),
                        //       // ),
                        //     ],
                        //   ),
                        // ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      // validator: (value) => value == null || value.isEmpty
                      //     ? 'Please Select Invoice Date'
                      //     : null,
                    ),
                  ],
                  const SizedBox(height: 20),
                  _sectionTitle("LR Number & Transport"),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: lrController,
                    inputFormatters: [SecureTextInputFormatter.deny()],
                    decoration: const InputDecoration(
                      labelText: 'LR Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownSearch<String>(
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
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: RichText(
                            text: const TextSpan(
                              text: 'Select Transport ',
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        baseStyle: const TextStyle(fontSize: 16),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please Select Transport'
                          : null,
                      onChanged: (String? selectedTransportName) {
                        if (selectedTransportName != null && mounted) {
                          transportController.selectedTransportVal?.value =
                              selectedTransportName;
                          setState(() {
                            _transportID = transportController.getTransportId(
                              selectedTransportName,
                            );
                          });
                        }
                      },
                      selectedItem:
                          transportController
                              .selectedTransportVal!
                              .value
                              .isNotEmpty
                          ? transportController.selectedTransportVal?.value
                          : null,
                      enabled: !transportController.isLoading.value,
                      dropdownBuilder: (context, selectedItem) => Container(
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    readOnly: true,
                    onTap: () => _selectDate(
                      context,
                      lrDateController,
                      (value) => _lrDate = value,
                    ),
                    controller: lrDateController,
                    decoration: InputDecoration(
                      labelText: 'LR Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: freightAmtController,
                    inputFormatters: [
                      SecureTextInputFormatter.deny(),
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(labelText: 'Freight Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: freightAmtController,
                    inputFormatters: [
                      SecureTextInputFormatter.deny(),
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Freight Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Search Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      items: statusController.getStatusNames(),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: RichText(
                            text: const TextSpan(
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
                          border: OutlineInputBorder(),
                        ),
                        baseStyle: const TextStyle(fontSize: 16),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please Select Status'
                          : null,
                      onChanged: (String? selectedStatusName) {
                        if (selectedStatusName != null) {
                          statusController.selectedStatusVal!.value =
                              selectedStatusName;
                          setState(() {
                            _statusID = statusController.getStatusId(
                              selectedStatusName,
                            );
                          });
                        } else {
                          statusController.selectedStatusVal!.value = '';
                          setState(() {
                            _statusID = null;
                          });
                        }
                      },
                      selectedItem:
                          statusController.selectedStatusVal!.value.isNotEmpty
                          ? statusController.selectedStatusVal!.value
                          : null,
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
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'Claim ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Radio(
                                  value: '1',
                                  groupValue: _claimType,
                                  onChanged: (value) => setState(() {
                                    _claimType = value as String;
                                    _claimTypeError = null;
                                  }),
                                ),
                                const Text('Yes'),
                                Radio(
                                  value: '0',
                                  groupValue: _claimType,
                                  onChanged: (value) => setState(() {
                                    _claimType = value as String;
                                    _claimTypeError = null;
                                  }),
                                ),
                                const Text('No'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_claimTypeError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Text(
                            _claimTypeError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle("Document Upload"),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      _buildFilePicker('LR Copy', 'lr_copy'),
                      Obx(
                        () => SizedBox(
                          child: controller.lrCopyFile.value == null
                              ? _viewButton("View", () {
                                  try {
                                    if (inwardid!.lrCopy == null ||
                                        inwardid!.lrCopy!.isEmpty) {
                                      // Get.snackbar(
                                      //   'Error',
                                      //   'No LR Copy available to view',
                                      // );
                                      return;
                                    }

                                    final filePath = inwardid!.lrCopy
                                        .toLowerCase();
                                    final url =
                                        '${inwardListController.url.value}${inwardid!.lrCopy}';

                                    if (filePath.endsWith('.pdf')) {
                                      Get.toNamed(
                                        AppRoutes.viewpdf,
                                        arguments: url,
                                      );
                                    } else if (filePath.endsWith('.jpg') ||
                                        filePath.endsWith('.png') ||
                                        filePath.endsWith('.jpeg')) {
                                      Get.toNamed(
                                        AppRoutes.viewImage,
                                        arguments: url,
                                      );
                                    } else {
                                      // Get.snackbar(
                                      //   'Error',
                                      //   'Unsupported file format for LR Copy',
                                      // );
                                    }
                                  } catch (e) {
                                    // Get.snackbar('Error', 'Failed to open LR Copy');
                                  }
                                })
                              : SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  if (_customerVendorType == "1")
                    Column(
                      children: [
                        _buildFilePicker('Debit Note Copy', 'debit_note_copy'),
                        Obx(
                          () => SizedBox(
                            child: controller.debitNoteCopyFile.value == null
                                ? _viewButton("View", () {
                                    try {
                                      if (inwardid!.debitNoteCopy == null ||
                                          inwardid!.debitNoteCopy.isEmpty) {
                                        // Get.snackbar(
                                        //   'Error',
                                        //   'No Debit Note Copy available to view',
                                        // );
                                        return;
                                      }

                                      final filePath = inwardid!.debitNoteCopy
                                          .toLowerCase();
                                      final url =
                                          '${inwardListController.url.value}${inwardid!.debitNoteCopy}';

                                      if (filePath.endsWith('.pdf')) {
                                        Get.toNamed(
                                          AppRoutes.viewpdf,
                                          arguments: url,
                                        );
                                      } else if (filePath.endsWith('.jpg') ||
                                          filePath.endsWith('.png') ||
                                          filePath.endsWith('.jpeg')) {
                                        Get.toNamed(
                                          AppRoutes.viewImage,
                                          arguments: url,
                                        );
                                      } else {
                                        // Get.snackbar(
                                        //   'Error',
                                        //   'Unsupported file format for Debit Note Copy',
                                        // );
                                      }
                                    } catch (e) {
                                      // Get.snackbar(
                                      //   'Error',
                                      //   'Failed to open Debit Note Copy',
                                      // );
                                    }
                                  })
                                : SizedBox.shrink(),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildFilePicker('Invoice Copy', 'invoice_copy'),
                        Obx(
                          () => SizedBox(
                            child: controller.invoiceCopyFile.value == null
                                ? _viewButton("View", () {
                                    try {
                                      if (inwardid!.invoiceCopy == null ||
                                          inwardid!.invoiceCopy!.isEmpty) {
                                        // Get.snackbar(
                                        //   'Error',
                                        //   'No Invoice Copy available to view',
                                        // );
                                        return;
                                      }

                                      final filePath = inwardid!.invoiceCopy!
                                          .toLowerCase();
                                      final url =
                                          '${inwardListController.url.value}${inwardid!.invoiceCopy}';

                                      if (filePath.endsWith('.pdf')) {
                                        Get.toNamed(
                                          AppRoutes.viewpdf,
                                          arguments: url,
                                        );
                                      } else if (filePath.endsWith('.jpg') ||
                                          filePath.endsWith('.png') ||
                                          filePath.endsWith('.jpeg')) {
                                        Get.toNamed(
                                          AppRoutes.viewImage,
                                          arguments: url,
                                        );
                                      } else {
                                        // Get.snackbar(
                                        //   'Error',
                                        //   'Unsupported file format for Invoice Copy',
                                        // );
                                      }
                                    } catch (e) {
                                      //  Get.snackbar('Error', 'Failed to open Invoice Copy');
                                    }
                                  })
                                : SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Center(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                _submitForm();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Submit',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
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

  Widget _viewButton(String label, VoidCallback press) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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

  Widget _sectionTitle(String title) {
    return RichText(
      text: TextSpan(
        text: title.replaceAll('*', ''),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        children: title.contains('*')
            ? [
                const TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}

class Company {
  final int id;
  final String name;
  Company(this.id, this.name);
  @override
  String toString() => name;
}

class Division {
  final int id;
  final String name;
  Division(this.id, this.name);
  @override
  String toString() => name;
}

class Customer {
  final int id;
  final String name;
  Customer(this.id, this.name);
  @override
  String toString() => name;
}
