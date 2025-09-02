import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:trailo/controller/inward/add_inward/add_inward_controller.dart';
import 'package:trailo/controller/global_controller/company/company_controller.dart';
import 'package:trailo/controller/global_controller/division/divsion_controller.dart';
import 'package:trailo/controller/global_controller/transport/transport_controller.dart';
import 'package:trailo/controller/global_controller/status/status_controller.dart';
import 'package:trailo/controller/global_controller/vendor/vendor_controller.dart';
import 'package:trailo/controller/global_controller/customers/customer_controller.dart';
import 'package:trailo/controller/inward/add_inward/check_debit_note_number_controller.dart';
import 'package:trailo/controller/inward/add_inward/check_inward_number_controller.dart';
import 'package:trailo/controller/inward/add_inward/check_vendor_invoice_number_controller.dart';
import 'package:trailo/utility/app_utility.dart';
import 'package:trailo/utility/app_colors.dart';
import '../../common/securetextinputformatter.dart';
import '../../controller/inward/add_inward/check_invoice_number_controller.dart';

class AddInwardScreen extends StatefulWidget {
  const AddInwardScreen({super.key});

  @override
  _AddInwardScreenState createState() => _AddInwardScreenState();
}

class _AddInwardScreenState extends State<AddInwardScreen> {
  final controller = Get.put(AddInwardController());
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

        // Clear text controllers
        receiptDateController.clear();
        inwardNumberController.clear();
        debitNoteController.clear();
        debitNoteDateController.clear();
        invoiceNumberController.clear();
        invoiceDateController.clear();
        lrController.clear();
        lrDateController.clear();
        freightAmtController.clear();

        // Reset GetX controller states
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
      });
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
      };

      controller.submitInwardData(data: data, context: context, id: "").then((
        success,
      ) {
        // if (success && mounted) {
        //   _clearForm();
        // }
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
          title: const Text("Add Inward"),
          backgroundColor: AppColors.primary,
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
                          onChanged: (value) async {
                            // await checkInwardController.verifyInwardNumber(
                            //   inwardNo: value,
                            //   inwardID: "",
                            //   context: context,
                            // );
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Inward Number';
                            }
                            // else if (checkInwardController.flag.value ==
                            //     "1") {
                            //   return 'No. Already Exists';
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
                        baseStyle: const TextStyle(fontSize: 16),
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
                  SizedBox(height: 16),
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
                            onChanged: (value) => setState(() {
                              _customerVendorType = value as String;
                              _customerVendorError = null;
                              _customerID = null;
                              _vendorID = null;
                              customerController.selectedCustomerVal?.value =
                                  '';
                              vendorController.selectedVendorVal?.value = '';
                              invoiceNumberController.clear();
                              invoiceDateController.clear();
                              debitNoteController.clear();
                              debitNoteDateController.clear();
                            }),
                          ),
                          const Text('Customer'),
                          Radio(
                            value: '0',
                            groupValue: _customerVendorType,
                            onChanged: (value) => setState(() {
                              _customerVendorType = value as String;
                              _customerVendorError = null;
                              _customerID = null;
                              _vendorID = null;
                              customerController.selectedCustomerVal?.value =
                                  '';
                              vendorController.selectedVendorVal?.value = '';
                              invoiceNumberController.clear();
                              invoiceDateController.clear();
                              debitNoteController.clear();
                              debitNoteDateController.clear();
                            }),
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
                                        .selectedCustomerVal
                                        ?.value
                                        .isEmpty ??
                                    true
                                ? null
                                : customerController.selectedCustomerVal?.value,
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
                                ),
                              ),
                            ),
                            items: vendorController.getVendorNames(),
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                label: RichText(
                                  text: TextSpan(
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
                                        .selectedVendorVal
                                        ?.value
                                        .isEmpty ??
                                    true
                                ? null
                                : vendorController.selectedVendorVal?.value,
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
                        //       inwardID: "",
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
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      controller: debitNoteDateController,
                      onTap: () => _selectDate(
                        context,
                        debitNoteDateController,
                        (value) => _debitNoteDate = value,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Debit Note Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
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
                        //   inwardID: "",
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
                    decoration: InputDecoration(labelText: 'LR Number'),
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
                          ),
                        ),
                      ),
                      items: transportController.getTransportNames(),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
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
                        ),
                        baseStyle: const TextStyle(fontSize: 16),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please Select Transport'
                          : null,
                      onChanged: (String? selectedTransportName) {
                        if (selectedTransportName != null && mounted) {
                          transportController.selectedTransportVal.value =
                              selectedTransportName;
                          setState(() {
                            _transportID = transportController.getTransportId(
                              selectedTransportName,
                            );
                          });
                        }
                      },
                      selectedItem: null,
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
                  const SizedBox(height: 16),
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
                        baseStyle: const TextStyle(fontSize: 16),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please Select Status'
                          : null,
                      onChanged: (String? selectedStatusName) {
                        if (selectedStatusName != null && mounted) {
                          statusController.selectedStatusVal?.value =
                              selectedStatusName;
                          setState(() {
                            _statusID = statusController.getStatusId(
                              selectedStatusName,
                            );
                          });
                        }
                      },
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
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RichText(
                            text: TextSpan(
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
                  _buildFilePicker('LR Copy', 'lr_copy'),
                  if (_customerVendorType == "1")
                    _buildFilePicker('Debit Note Copy', 'debit_note_copy')
                  else
                    _buildFilePicker('Invoice Copy', 'invoice_copy'),
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
                TextSpan(
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
