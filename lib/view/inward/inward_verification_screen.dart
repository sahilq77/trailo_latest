import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:trailo/controller/global_controller/employee/store_employee_controller.dart';
import 'package:trailo/controller/inward/inward_verification_controller.dart';
import 'package:trailo/controller/global_controller/employee/employee_controller.dart';
import 'package:trailo/controller/global_controller/status/status_controller.dart';
import 'package:trailo/model/inward_list/get_inward_list_response.dart';
import 'package:trailo/utility/app_utility.dart';
import 'package:trailo/utility/app_colors.dart';
import '../../common/securetextinputformatter.dart';
import '../../../core/urls.dart';
import '../../../core/network/exceptions.dart';
import '../../utility/date_formater.dart';

class InwardVerificationScreen extends StatefulWidget {
  const InwardVerificationScreen({super.key});

  @override
  _InwardVerificationScreenState createState() =>
      _InwardVerificationScreenState();
}

class _InwardVerificationScreenState extends State<InwardVerificationScreen> {
  final StatusController statusController = Get.put(StatusController());
  final EmployeeController employeeController = Get.put(EmployeeController());
  final StoreEmployeeController storeEmployeeController = Get.put(
    StoreEmployeeController(),
  );
  final InwardVerificationController controller = Get.put(
    InwardVerificationController(),
  );
  final _formKey = GlobalKey<FormState>();
  final remarkController = TextEditingController();
  final debitNoteNumberController = TextEditingController();
  final inwardNumberController = TextEditingController();
  final invoiceNumberController = TextEditingController();
  final invoiceDateController = TextEditingController();
  final debitNoteDateController = TextEditingController();
  bool _isEnabled = true;
  String? _statusID;
  String? _mrnPreparedByID;
  String? _mrnCheckedByID;
  String? _stocksArrangedBy;
  String? _partyType = '1'; // Default to Customer
  DateTime? _invoiceDate;
  DateTime? _debitNoteDate;
  InwardListData? inward;
  List<Map<String, dynamic>> creditFields = [
    {
      'number': TextEditingController(),
      'fileName': Rxn<String>(),
      'file': Rxn<PlatformFile>(),
    },
  ];
  List<Map<String, dynamic>> grnFields = [
    {
      'number': TextEditingController(),
      'fileName': Rxn<String>(),
      'file': Rxn<PlatformFile>(),
    },
  ];

  void _loadData() {
    log('Loading data for inward: ${inward?.toJson()}');
    setState(() {
      inwardNumberController.text = inward!.inwardNumber.toString();
      debitNoteNumberController.text = inward!.debitNoteNumber.toString();
      debitNoteDateController.text = DateFormater.formatDate(
        inward!.debitNoteDate.toString(),
      );
      invoiceNumberController.text = inward!.vendorInvoiceNumber.toString();
      invoiceDateController.text = DateFormater.formatDate(
        inward!.vendorInvoiceDate.toString(),
      );
      _partyType = inward!.entityType.toString();
    });
    log(
      'Loaded data: inwardNumber=${inwardNumberController.text}, '
      'debitNoteNumber=${debitNoteNumberController.text}, '
      'debitNoteDate=${debitNoteDateController.text}, '
      'invoiceNumber=${invoiceNumberController.text}, '
      'invoiceDate=${invoiceDateController.text}, '
      'partyType=$_partyType',
    );
  }

  @override
  void initState() {
    super.initState();
    final inwardData = Get.arguments as InwardListData;
    setState(() {
      inward = inwardData;
    });
    log(
      'Initializing InwardVerificationScreen with inwardData: ${inwardData.toJson()}',
    );
    _loadData();
  }

  @override
  void dispose() {
    log('Disposing InwardVerificationScreen');
    remarkController.dispose();
    debitNoteNumberController.dispose();
    inwardNumberController.dispose();
    invoiceNumberController.dispose();
    invoiceDateController.dispose();
    debitNoteDateController.dispose();
    for (var field in creditFields) {
      field['number']!.dispose();
      log('Disposed credit field number controller');
    }
    for (var field in grnFields) {
      field['number']!.dispose();
      log('Disposed GRN field number controller');
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    log('Validating form');
    if (_formKey.currentState!.validate()) {
      log('Form validated, preparing data');
      // Prepare credit note data
      final creditNumbers = creditFields
          .map((e) => e['number'].text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      final creditFiles = creditFields
          .where((e) => e['file'].value != null)
          .map((e) => e['file'].value as PlatformFile)
          .toList();
      log('Credit numbers: $creditNumbers');
      log('Credit files: ${creditFiles.map((f) => f.name).toList()}');

      // Validate credit note files
      if (_partyType == '1' && creditFiles.isEmpty) {
        log('Validation failed: No credit note files for customer');
        Get.snackbar(
          'Error',
          'At least one credit note copy is required for customer',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (_partyType == '1' && creditFiles.length != creditNumbers.length) {
        log(
          'Validation failed: Number of credit note files (${creditFiles.length}) does not match number of credit notes (${creditNumbers.length})',
        );
        Get.snackbar(
          'Error',
          'Each credit number must have an associated file',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Prepare GRN data
      final grnNumbers = grnFields
          .map((e) => e['number'].text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      final grnFiles = grnFields
          .where((e) => e['file'].value != null)
          .map((e) => e['file'].value as PlatformFile)
          .toList();
      log('GRN numbers: $grnNumbers');
      log('GRN files: ${grnFiles.map((f) => f.name).toList()}');

      // Validate GRN files
      if (_partyType == '0' && grnFiles.isEmpty) {
        log('Validation failed: No GRN files for vendor');
        Get.snackbar(
          'Error',
          'At least one GRN copy is required for vendor',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (_partyType == '0' && grnFiles.length != grnNumbers.length) {
        log(
          'Validation failed: Number of GRN files (${grnFiles.length}) does not match number of GRN numbers (${grnNumbers.length})',
        );
        Get.snackbar(
          'Error',
          'Each GRN number must have an associated file',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Assign files to controller
      log(
        'Assigning files to controller: creditFiles=${creditFiles.length}, grnFiles=${grnFiles.length}',
      );
      controller.creditNoteFiles.value = creditFiles;
      controller.grnFiles.value = grnFiles;
      log(
        'Controller creditNoteFiles: ${controller.creditNoteFiles.map((f) => f.name).toList()}',
      );
      log(
        'Controller grnFiles: ${controller.grnFiles.map((f) => f.name).toList()}',
      );

      // Prepare form data
      final data = {
        'employee_id': AppUtility.userID.toString(),
        'inward_id': inward!.id?.toString() ?? '',
        'inward_number': inward!.inwardNumber?.toString() ?? '',
        'status_id': _statusID ?? '',
        'mrn_prepared_by': _mrnPreparedByID ?? '',
        'mrn_checked_by': _mrnCheckedByID ?? '',
        'stocks_arranged_by': _stocksArrangedBy ?? '',
        'remark': remarkController.text.trim(),
        'entity_type': _partyType ?? '',
        'debit_no': debitNoteNumberController.text.trim(),
        'debit_date': _debitNoteDate?.toIso8601String().split('T')[0] ?? '',
        'credit_no': creditNumbers,
        'Invoice_number': invoiceNumberController.text.trim(),
        'Invoice_date': _invoiceDate?.toIso8601String().split('T')[0] ?? '',
        'grn_numbers': grnNumbers,
      };
      log('Form data prepared: $data');

      await controller.submitInwardVerificationData(
        data: data,
        context: context,
        id: inward!.id.toString(),
      );
      log("Request Body===>$data");
    } else {
      log('Form validation failed');
    }
  }

  Future<void> _pickCreditFile(int index) async {
    try {
      log('Picking credit note file for index: $index');
      await controller.pickFile('credit_note_copy', allowMultiple: false);
      log(
        'Picked file: ${controller.creditNoteFiles.isNotEmpty ? controller.creditNoteFiles[0].name : "None"}',
      );
      if (controller.creditNoteFiles.isNotEmpty) {
        setState(() {
          final file = controller.creditNoteFiles[0];
          creditFields[index]['fileName'].value = file.name;
          creditFields[index]['file'].value = file;
          controller.creditNoteFiles.clear();
          for (var field in creditFields) {
            if (field['file'].value != null) {
              controller.creditNoteFiles.add(field['file'].value!);
            }
          }
          log(
            'Updated creditFields[$index]: fileName=${file.name}, controller.creditNoteFiles=${controller.creditNoteFiles.map((f) => f.name).toList()}',
          );
        });
      } else {
        log('No file selected for credit note copy');
        Get.snackbar(
          'Info',
          'No file selected for credit note copy',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      log('Error picking credit note file: $e', stackTrace: stackTrace);
      Get.snackbar(
        'Error',
        'Failed to pick credit note file: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _pickGrnFile(int index) async {
    try {
      log('Picking GRN file for index: $index');
      await controller.pickFile('grn_copy', allowMultiple: false);
      log(
        'Picked file: ${controller.grnFiles.isNotEmpty ? controller.grnFiles[0].name : "None"}',
      );
      if (controller.grnFiles.isNotEmpty) {
        setState(() {
          final file = controller.grnFiles[0];
          grnFields[index]['fileName'].value = file.name;
          grnFields[index]['file'].value = file;
          controller.grnFiles.clear();
          for (var field in grnFields) {
            if (field['file'].value != null) {
              controller.grnFiles.add(field['file'].value!);
            }
          }
          log(
            'Updated grnFields[$index]: fileName=${file.name}, controller.grnFiles=${controller.grnFiles.map((f) => f.name).toList()}',
          );
        });
      } else {
        log('No file selected for GRN copy');
        Get.snackbar(
          'Info',
          'No file selected for GRN copy',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e, stackTrace) {
      log('Error picking GRN file: $e', stackTrace: stackTrace);
      Get.snackbar(
        'Error',
        'Failed to pick GRN file: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    log('Building InwardVerificationScreen');
    return Scaffold(
      appBar: AppBar(title: const Text('Inward Verification')),
      body: Obx(
        () => Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: inwardNumberController,
                        decoration: InputDecoration(
                          label: RichText(
                            text: TextSpan(
                              text: 'Inward Number ',
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
                        validator: (value) =>
                            value!.isEmpty ? 'Inward Number is required' : null,
                        readOnly: true,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      DropdownSearch<String>(
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
                          log('Status selected: $selectedStatusName');
                          if (selectedStatusName != null) {
                            statusController.selectedStatusVal?.value =
                                selectedStatusName;
                            String? statusId = statusController.getStatusId(
                              selectedStatusName,
                            );
                            setState(() {
                              _statusID = statusId;
                            });
                            log('Status ID set: $_statusID');
                          }
                        },
                        selectedItem: null,
                        enabled: !statusController.isLoading.value,
                        dropdownBuilder: (context, selectedItem) {
                          return Text(
                            selectedItem ?? 'Select Status',
                            style: TextStyle(
                              fontSize: 16,
                              color: statusController.isLoading.value
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          );
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Select Status'
                            : null,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: 'Search Employee',
                            ),
                          ),
                        ),
                        items: employeeController.getEmployeeNames(),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            label: RichText(
                              text: TextSpan(
                                text: 'MRN Prepared By ',
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
                        onChanged: (String? selectedEmployeeName) {
                          log(
                            'MRN Prepared By selected: $selectedEmployeeName',
                          );
                          if (selectedEmployeeName != null) {
                            employeeController.selectedEmployeeVal?.value =
                                selectedEmployeeName;
                            String? employeeId = employeeController
                                .getEmployeeId(selectedEmployeeName);
                            setState(() {
                              _mrnPreparedByID = employeeId;
                            });
                            log('MRN Prepared By ID set: $_mrnPreparedByID');
                          }
                        },
                        selectedItem: null,
                        enabled: !employeeController.isLoading.value,
                        dropdownBuilder: (context, selectedItem) {
                          return Text(
                            selectedItem ?? 'Select Employee',
                            style: TextStyle(
                              fontSize: 16,
                              color: employeeController.isLoading.value
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          );
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Select MRN Prepared By'
                            : null,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      DropdownSearch<String>(
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              labelText: 'Search Employee',
                            ),
                          ),
                        ),
                        items: employeeController.getEmployeeNames(),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            label: RichText(
                              text: TextSpan(
                                text: 'MRN Checked By ',
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
                        onChanged: (String? selectedEmployeeName) {
                          log('MRN Checked By selected: $selectedEmployeeName');
                          if (selectedEmployeeName != null) {
                            employeeController.selectedEmployeeVal?.value =
                                selectedEmployeeName;
                            String? employeeId = employeeController
                                .getEmployeeId(selectedEmployeeName);
                            setState(() {
                              _mrnCheckedByID = employeeId;
                            });
                            log('MRN Checked By ID set: $_mrnCheckedByID');
                          }
                        },
                        selectedItem: null,
                        enabled: !employeeController.isLoading.value,
                        dropdownBuilder: (context, selectedItem) {
                          return Text(
                            selectedItem ?? 'Select Employee',
                            style: TextStyle(
                              fontSize: 16,
                              color: employeeController.isLoading.value
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          );
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Select MRN Checked By'
                            : null,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      DropdownSearch<String>(
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
                          searchFieldProps: const TextFieldProps(
                            decoration: InputDecoration(
                              labelText: 'Search Employee',
                            ),
                          ),
                          loadingBuilder: (context, searchTerm) =>
                              const Center(child: CircularProgressIndicator()),
                          emptyBuilder: (context, searchTerm) =>
                              const Center(child: Text('No employees found')),
                          errorBuilder: (context, searchTerm, exception) =>
                              Center(
                                child: Text(
                                  storeEmployeeController
                                          .errorMessage
                                          .value
                                          .isNotEmpty
                                      ? storeEmployeeController
                                            .errorMessage
                                            .value
                                      : 'Error loading employees',
                                ),
                              ),
                        ),
                        items: storeEmployeeController.getStoreEmployeeNames(),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            label: RichText(
                              text: TextSpan(
                                text: 'Stocks Arranged By ',
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
                        onChanged: (String? selectedEmployeeName) {
                          log(
                            'Stocks Arranged By selected: $selectedEmployeeName',
                          );
                          if (selectedEmployeeName != null) {
                            storeEmployeeController
                                    .selectedStoreEmployeeVal
                                    ?.value =
                                selectedEmployeeName;
                            String? employeeId = storeEmployeeController
                                .getStoreEmployeeId(selectedEmployeeName);
                            setState(() {
                              _stocksArrangedBy = employeeId;
                            });
                            log(
                              'Stocks Arranged By ID set: $_stocksArrangedBy',
                            );
                          }
                        },
                        selectedItem: null,
                        enabled: !storeEmployeeController.isLoading.value,
                        dropdownBuilder: (context, selectedItem) {
                          return Text(
                            selectedItem ?? 'Select Employee',
                            style: TextStyle(
                              fontSize: 16,
                              color: storeEmployeeController.isLoading.value
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please Select Stocks Arranged By'
                            : null,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        inputFormatters: [SecureTextInputFormatter.deny()],
                        controller: remarkController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Remark'),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Row(
                        children: [
                          Radio(
                            value: '1',
                            groupValue: _partyType,
                            onChanged: null,
                            activeColor: Colors.grey,
                          ),
                          const Text('Customer'),
                          Radio(
                            value: '0',
                            groupValue: _partyType,
                            onChanged: null,
                            activeColor: Colors.grey,
                          ),
                          const Text('Vendor'),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        child: _partyType == "1"
                            ? Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.02),
                                  TextFormField(
                                    controller: debitNoteNumberController,
                                    inputFormatters: [
                                      SecureTextInputFormatter.deny(),
                                    ],
                                    decoration: InputDecoration(
                                      label: RichText(
                                        text: TextSpan(
                                          text: 'Debit Number ',
                                          style: TextStyle(color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: '*',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    validator: (value) => value!.isEmpty
                                        ? 'Debit Number is required'
                                        : null,
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  TextFormField(
                                    controller: debitNoteDateController,
                                    decoration: InputDecoration(
                                      label: RichText(
                                        text: TextSpan(
                                          text: 'Debit Note Date ',
                                          style: TextStyle(color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: '*',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      log('Opening date picker for debit note');
                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _debitNoteDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _debitNoteDate = picked;
                                          debitNoteDateController.text = picked
                                              .toLocal()
                                              .toString()
                                              .split(' ')[0];
                                          log(
                                            'Debit note date set: ${debitNoteDateController.text}',
                                          );
                                        });
                                      }
                                    },
                                    validator: (value) => value!.isEmpty
                                        ? 'Debit Note Date is required'
                                        : null,
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  ...creditFields.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  inputFormatters: [
                                                    SecureTextInputFormatter.deny(),
                                                  ],
                                                  controller:
                                                      creditFields[index]['number'],
                                                  decoration: InputDecoration(
                                                    label: RichText(
                                                      text: TextSpan(
                                                        text:
                                                            'Enter Credit Number ${index + 1} ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        children: [
                                                          // TextSpan(
                                                          //   text: '*',
                                                          //   style: TextStyle(
                                                          //     color: Colors.red,
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  // validator: (value) =>
                                                  //     value!.isEmpty
                                                  //     ? 'Credit Number is required'
                                                  //     : null,
                                                ),
                                                SizedBox(height: 16.0),
                                                Obx(
                                                  () => Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Credit Note Copy',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        creditFields[index]['fileName']
                                                                .value ??
                                                            'No file selected',
                                                        style: TextStyle(
                                                          color:
                                                              creditFields[index]['fileName']
                                                                      .value ==
                                                                  null
                                                              ? Colors.grey
                                                              : Colors.black,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Row(
                                                        children: [
                                                          TextButton(
                                                            onPressed: () async {
                                                              await _pickCreditFile(
                                                                index,
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Choose File',
                                                            ),
                                                          ),
                                                          if (creditFields[index]['fileName']
                                                                  .value !=
                                                              null)
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  creditFields[index]['fileName']
                                                                          .value =
                                                                      null;
                                                                  creditFields[index]['file']
                                                                          .value =
                                                                      null;
                                                                  controller
                                                                      .creditNoteFiles
                                                                      .clear();
                                                                  for (var field
                                                                      in creditFields) {
                                                                    if (field['file']
                                                                            .value !=
                                                                        null) {
                                                                      controller
                                                                          .creditNoteFiles
                                                                          .add(
                                                                            field['file'].value!,
                                                                          );
                                                                    }
                                                                  }
                                                                  log(
                                                                    'Removed credit file at index: $index',
                                                                  );
                                                                });
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (creditFields.length > 1)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  creditFields[index]['number']!
                                                      .dispose();
                                                  creditFields.removeAt(index);
                                                  controller.creditNoteFiles
                                                      .clear();
                                                  for (var field
                                                      in creditFields) {
                                                    if (field['file'].value !=
                                                        null) {
                                                      controller.creditNoteFiles
                                                          .add(
                                                            field['file']
                                                                .value!,
                                                          );
                                                    }
                                                  }
                                                  log(
                                                    'Removed credit field at index: $index',
                                                  );
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        creditFields.add({
                                          'number': TextEditingController(),
                                          'fileName': Rxn<String>(),
                                          'file': Rxn<PlatformFile>(),
                                        });
                                        log('Added new credit field');
                                      });
                                    },
                                    child: const Text('+ Add Credit Number'),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.02),
                                  TextFormField(
                                    readOnly: true,
                                    controller: invoiceNumberController,
                                    decoration: InputDecoration(
                                      label: RichText(
                                        text: TextSpan(
                                          text: 'Invoice Number ',
                                          style: TextStyle(color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: '*',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    validator: (value) => value!.isEmpty
                                        ? 'Invoice Number is required'
                                        : null,
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  TextFormField(
                                    inputFormatters: [
                                      SecureTextInputFormatter.deny(),
                                    ],

                                    controller: invoiceDateController,
                                    decoration: InputDecoration(
                                      label: RichText(
                                        text: TextSpan(
                                          text: 'Invoice Date ',
                                          style: TextStyle(color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: '*',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    readOnly: true,
                                    // onTap: () async {
                                    //   log(
                                    //     'Opening date picker for invoice date',
                                    //   );
                                    //   DateTime? picked = await showDatePicker(
                                    //     context: context,
                                    //     initialDate:
                                    //         _invoiceDate ?? DateTime.now(),
                                    //     firstDate: DateTime(2000),
                                    //     lastDate: DateTime(2100),
                                    //   );
                                    //   if (picked != null) {
                                    //     setState(() {
                                    //       _invoiceDate = picked;
                                    //       invoiceDateController.text = picked
                                    //           .toLocal()
                                    //           .toString()
                                    //           .split(' ')[0];
                                    //       log(
                                    //         'Invoice date set: ${invoiceDateController.text}',
                                    //       );
                                    //     });
                                    //   }
                                    // },
                                    // validator: (value) => value!.isEmpty
                                    //     ? 'Invoice Date is required'
                                    //     : null,
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  ...grnFields.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  inputFormatters: [
                                                    SecureTextInputFormatter.deny(),
                                                  ],
                                                  controller:
                                                      grnFields[index]['number'],
                                                  decoration: InputDecoration(
                                                    label: RichText(
                                                      text: TextSpan(
                                                        text:
                                                            'Enter GRN Number ${index + 1} ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        children: [
                                                          // TextSpan(
                                                          //   text: '*',
                                                          //   style: TextStyle(
                                                          //     color: Colors.red,
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  // validator: (value) =>
                                                  //     value!.isEmpty
                                                  //     ? 'GRN Number is required'
                                                  //     : null,
                                                ),
                                                SizedBox(height: 16.0),
                                                Obx(
                                                  () => Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'GRN Copy',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        grnFields[index]['fileName']
                                                                .value ??
                                                            'No file selected',
                                                        style: TextStyle(
                                                          color:
                                                              grnFields[index]['fileName']
                                                                      .value ==
                                                                  null
                                                              ? Colors.grey
                                                              : Colors.black,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Row(
                                                        children: [
                                                          TextButton(
                                                            onPressed: () async {
                                                              await _pickGrnFile(
                                                                index,
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Choose File',
                                                            ),
                                                          ),
                                                          if (grnFields[index]['fileName']
                                                                  .value !=
                                                              null)
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  grnFields[index]['fileName']
                                                                          .value =
                                                                      null;
                                                                  grnFields[index]['file']
                                                                          .value =
                                                                      null;
                                                                  controller
                                                                      .grnFiles
                                                                      .clear();
                                                                  for (var field
                                                                      in grnFields) {
                                                                    if (field['file']
                                                                            .value !=
                                                                        null) {
                                                                      controller
                                                                          .grnFiles
                                                                          .add(
                                                                            field['file'].value!,
                                                                          );
                                                                    }
                                                                  }
                                                                  log(
                                                                    'Removed GRN file at index: $index',
                                                                  );
                                                                });
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (grnFields.length > 1)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  grnFields[index]['number']!
                                                      .dispose();
                                                  grnFields.removeAt(index);
                                                  controller.grnFiles.clear();
                                                  for (var field in grnFields) {
                                                    if (field['file'].value !=
                                                        null) {
                                                      controller.grnFiles.add(
                                                        field['file'].value!,
                                                      );
                                                    }
                                                  }
                                                  log(
                                                    'Removed GRN field at index: $index',
                                                  );
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        grnFields.add({
                                          'number': TextEditingController(),
                                          'fileName': Rxn<String>(),
                                          'file': Rxn<PlatformFile>(),
                                        });
                                        log('Added new GRN field');
                                      });
                                    },
                                    child: const Text('+ Add GRN Number'),
                                  ),
                                ],
                              ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildFilePicker("MRN Copy", "mrn_copy"),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                log('Submit button pressed');
                                _submitForm();
                              },
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker(String label, String field) {
    log('Building file picker for field: $field');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.getFileNames(field)?.isEmpty ?? true)
                const Text(
                  'No file selected',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...?controller
                    .getFileNames(field)
                    ?.map(
                      (fileName) => ListTile(
                        title: Text(
                          fileName,
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: () {
                            setState(() {
                              if (field == 'mrn_copy') {
                                controller.mrnCopyFile.value = null;
                                log('Cleared MRN copy file');
                              }
                            });
                          },
                        ),
                      ),
                    ),
              TextButton(
                onPressed: () {
                  log('File picker button pressed for field: $field');
                  controller.pickFile(field, allowMultiple: false);
                },
                child: const Text('Choose File'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
