import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:trailo/controller/outward/packed_outword/add_outward_movement_controller.dart';
import 'package:trailo/utility/date_formater.dart';
import '../../../common/securetextinputformatter.dart';
import '../../../controller/outward/packed_outword/packed_by_list_controller.dart';
import '../../../model/packed_by_list/packed_by_list_response.dart';
import '../../../utility/app_utility.dart';

class OutwardMovementForm extends StatefulWidget {
  @override
  _OutwardMovementFormState createState() => _OutwardMovementFormState();
}

class _OutwardMovementFormState extends State<OutwardMovementForm> {
  final controller = Get.put(AddOutwardMovementController());
  final _formKey = GlobalKey<FormState>();
  String? _selectedFileName;
  File? _selectedFile;
  String? _materialReceiptDate;

  // Controllers for text fields
  final _invoiceNumberController = TextEditingController();
  final _invoiceDateController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _placeController = TextEditingController();
  final _materialReceiptDateController = TextEditingController(
    text: 'Select Material Receipt Date',
  );
  final _confirmedByController = TextEditingController();

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _invoiceDateController.dispose();
    _customerNameController.dispose();
    _placeController.dispose();
    _materialReceiptDateController.dispose();
    _confirmedByController.dispose();
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
        controller.delProofFile.value = result.files.single;
      });
    }
  }

  // Function to show date picker for material receipt date
  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      String displayDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      String apiDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        _materialReceiptDateController.text = displayDate;
        _materialReceiptDate = apiDate;
      });
    }
  }

  PackedByListData? packedBy;
  final listcontroller = Get.put(PackedByListController());

  _loadData() {
    setState(() {
      _invoiceNumberController.text = packedBy!.invoiceNumberProcess.toString();
      _invoiceDateController.text = packedBy!.invoiceDateProcess != null
          ? DateFormat(
              'dd-MM-yyyy HH:mm:ss',
            ).format(packedBy!.invoiceDateProcess!)
          : '';
      _customerNameController.text = packedBy!.customerName.toString();
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validate required file (delProofFile)
      if (controller.delProofFile.value == null) {
        Get.snackbar(
          'Error',
          'Please select a Proof of Delivery file',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validate material receipt date
      if (_materialReceiptDate == null || _materialReceiptDate!.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select a Material Receipt Date',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final data = <String, String>{
        'employee_id': AppUtility.userID?.toString() ?? '',
        'user_type': AppUtility.userType?.toString() ?? '',
        'customer_id': packedBy!.customerId?.toString() ?? '',
        'outward_id': packedBy!.id?.toString() ?? '',
        'invoice_number': packedBy!.invoiceNumberProcess?.toString() ?? '',
        'invoice_date': packedBy!.invoiceDateProcess != null
            ? DateFormat(
                'yyyy-MM-dd HH:mm:ss',
              ).format(packedBy!.invoiceDateProcess!)
            : '',
        'place': _placeController.text,
        'material_receipt_date': _materialReceiptDate ?? '',
        'confirmed_by': _confirmedByController.text,
        'proof_of_delivery': controller.delProofFile.value?.name ?? '',
        'outward_movement_id': '',
      };

      controller.submitOutwardMovementData(
        data: data,
        context: context,
        id: packedBy!.id?.toString() ?? '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Outward Movement')),
      body: Column(
        children: [
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _invoiceNumberController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        labelText: 'Invoice Number',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _invoiceDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        labelText: 'Invoice Date',
                        hintText: 'DD-MM-YYYY HH:MM:SS',
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _customerNameController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        labelText: 'Customer Name',
                      ),
                    ),
                    SizedBox(height: 12.0),
                    TextFormField(
                      controller: _placeController,
                      inputFormatters: [SecureTextInputFormatter.deny()],
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Place ',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a place';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _materialReceiptDateController,
                      readOnly: true,
                      onTap: () => _selectDateTime(context),
                      inputFormatters: [SecureTextInputFormatter.deny()],
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Date Of Material Receipt ',
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
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value == 'Select Material Receipt Date') {
                          return 'Please select a material receipt date';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmedByController,
                      inputFormatters: [SecureTextInputFormatter.deny()],
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Confirmed By (Party Person) ',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the name of the confirming person';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.0),
                    _buildFilePicker(
                      "Upload Proof Of Delivery *",
                      "proof_of_delivery",
                    ),
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
            text: label.replaceAll('*', ''),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
