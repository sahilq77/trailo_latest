import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:trailo/controller/outward/packed_outword/add_outword_stock_movement_controller.dart';
import 'package:trailo/utility/app_utility.dart';
import 'dart:io';

import '../../../common/securetextinputformatter.dart';
import '../../../controller/global_controller/transport/transport_controller.dart';
import '../../../controller/outward/packed_outword/packed_by_list_controller.dart';
import '../../../model/packed_by_list/packed_by_list_response.dart';
import '../../../utility/app_colors.dart';

class StockMovementForm extends StatefulWidget {
  @override
  _StockMovementFormState createState() => _StockMovementFormState();
}

class _StockMovementFormState extends State<StockMovementForm> {
  final TransportController transportController = Get.put(
    TransportController(),
  );
  final controller = Get.put(AddOutwordStockMovementController());
  final _formKey = GlobalKey<FormState>();
  String? _transportID;
  String? _selectedFileName;
  File? _selectedFile;
  String? _lrDate, _deliveryDate;

  // Controllers for text fields
  final _invoiceController = TextEditingController();
  final _companyController = TextEditingController();
  final _divisionController = TextEditingController();
  final _casesController = TextEditingController();
  final _weightController = TextEditingController();
  final _freight1Controller = TextEditingController();
  final _freight2Controller = TextEditingController();
  final _lrNumberController = TextEditingController();
  final _lrDateController = TextEditingController();
  final _deliveryDateController = TextEditingController(
    text: 'Select Expected Delivery Date ',
  );

  @override
  void dispose() {
    _invoiceController.dispose();
    _companyController.dispose();
    _divisionController.dispose();
    _casesController.dispose();
    _weightController.dispose();
    _freight1Controller.dispose();
    _freight2Controller.dispose();
    _lrNumberController.dispose();
    _lrDateController.dispose();
    _deliveryDateController.dispose();
    super.dispose();
  }

  // Function to handle file picking
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
      });
    }
  }

  PackedByListData? packedBy;
  final listController = Get.put(PackedByListController());

  _loadData() {
    setState(() {
      _invoiceController.text = packedBy!.invoiceNumberProcess.toString();
      _divisionController.text = packedBy!.divisionName.toString();
      _companyController.text = packedBy!.companyName.toString();
      _casesController.text = packedBy!.numOfCases.toString();
      _weightController.text = packedBy!.weight.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    final outwardData = Get.arguments as PackedByListData;
    setState(() {
      packedBy = outwardData;
    });
    _loadData();
  }

  Future<void> _selectDate(BuildContext context, bool isLRDate) async {
    DateTime? initialDate;
    DateTime? firstDate;
    DateTime lastDate;

    if (isLRDate && packedBy!.invoiceDateProcess != null) {
      // Parse the invoice date to set as the minimum date for LR date
      initialDate = packedBy!.invoiceDateProcess!;
      firstDate = initialDate.subtract(
        Duration(days: 2),
      ); // 2 days before invoice date
      lastDate = DateTime(2030); // Allow future dates
    } else {
      initialDate = DateTime.now();
      firstDate = isLRDate
          ? packedBy!.invoiceDateProcess!.subtract(Duration(days: 2))
          : DateTime.now();
      lastDate = DateTime(2030); // Allow future dates
    }

    // Pick Date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(DateTime.now()) && isLRDate
          ? initialDate
          : DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      if (isLRDate) {
        // Pick Time for LR Date
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
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
          // Validate LR date is after invoice date
          if (packedBy!.invoiceDateProcess != null &&
              selectedDateTime.isBefore(packedBy!.invoiceDateProcess!)) {
            Get.snackbar(
              'Error',
              'LR date and time must be after the invoice date and time.',
              backgroundColor: AppColors.error,
              colorText: Colors.white,
            );
            return;
          }
          String displayDateTime = DateFormat(
            'dd-MM-yyyy HH:mm:ss',
          ).format(selectedDateTime);
          String apiDateTime = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(selectedDateTime);
          setState(() {
            _lrDateController.text = displayDateTime;
            _lrDate = apiDateTime;
          });
        }
      } else {
        // Only date for Expected Delivery Date
        // Ensure delivery date is not in the past
        if (pickedDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
          Get.snackbar(
            'Error',
            'Expected delivery date cannot be in the past.',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
          return;
        }
        String displayDate = DateFormat('dd-MM-yyyy').format(pickedDate);
        String apiDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        setState(() {
          _deliveryDateController.text = displayDate;
          _deliveryDate = apiDate;
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // if (_deliveryDate == null || _deliveryDate!.isEmpty) {
      //   Get.snackbar(
      //     'Error',
      //     'Please select an Expected Delivery Date and Time',
      //     backgroundColor: AppColors.error,
      //     colorText: Colors.white,
      //   );
      //   return;
      // }

      // Additional validation for LR date
      if (_lrDate != null && packedBy!.invoiceDateProcess != null) {
        DateTime lrDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(_lrDate!);
        if (lrDate.isBefore(packedBy!.invoiceDateProcess!)) {
          Get.snackbar(
            'Error',
            'LR date and time must be after the invoice date and time.',
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
          return;
        }
      }

      final data = <String, String>{
        'employee_id': AppUtility.userID?.toString() ?? '',
        'user_type': AppUtility.userType?.toString() ?? '',
        'company_id': packedBy!.companyId?.toString() ?? '',
        'division_id': packedBy!.divisionId?.toString() ?? '',
        'outward_id': packedBy!.id?.toString() ?? '',
        'transport_id': _transportID ?? '',
        'invoice_number': packedBy!.invoiceNumberProcess?.toString() ?? '',
        'no_of_cases': packedBy!.numOfCases?.toString() ?? '',
        'weight': packedBy!.weight?.toString() ?? '',
        'freight_amount_one': _freight1Controller.text,
        'freight_amount_two': _freight2Controller.text,
        'lr_number': _lrNumberController.text,
        'lr_date': _lrDate ?? '',
        'expected_delivery_date': _deliveryDate ?? '',
        'lr_copy': controller.lrCopyFile.value?.name ?? '',
        'stock_movement_id': '',
      };
      controller.submitStockMovementData(
        data: data,
        context: context,
        id: packedBy!.id?.toString() ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Movement')),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUnfocus,

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _invoiceController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        labelText: 'Invoice Number',
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _companyController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        labelText: 'Company Name',
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _divisionController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        labelText: 'Division',
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _casesController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        labelText: 'No Of Cases',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _weightController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        labelText: 'Weight',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12.0),
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
                          baseStyle: TextStyle(fontSize: 16),
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
                            print("Transport ID $_transportID");
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
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _freight1Controller,
                      inputFormatters: [
                        SecureTextInputFormatter.deny(),
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Freight Amount 1 ',
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
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter freight amount' : null,
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _freight2Controller,
                      inputFormatters: [
                        SecureTextInputFormatter.deny(),
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Freight Amount 2',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _lrDateController,
                      inputFormatters: [SecureTextInputFormatter.deny()],
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'LR Date ',
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                        hintText: 'DD-MM-YYYY HH:MM:SS',
                      ),
                      onTap: () => _selectDate(context, true),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select LR Date and Time';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      readOnly: true,
                      controller: _deliveryDateController,
                      inputFormatters: [SecureTextInputFormatter.deny()],
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Expected Delivery Date ',
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                        hintText: 'DD-MM-YYYY',
                      ),
                      onTap: () => _selectDate(context, false),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value == 'Select Expected Delivery Date ') {
                          return 'Please select Expected Delivery Date';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    _buildFilePicker("LR Copy", "lr_copy"),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _submitForm();
                },
                child: Text(
                  'Submit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 12.0,
                  ),
                  minimumSize: Size(150, 48),
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
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
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
}
