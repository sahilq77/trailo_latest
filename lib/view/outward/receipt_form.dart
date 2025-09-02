import 'package:flutter/material.dart';

class ReceiptForm extends StatefulWidget {
  @override
  _ReceiptFormState createState() => _ReceiptFormState();
}

class _ReceiptFormState extends State<ReceiptForm> {
  final _formKey = GlobalKey<FormState>();
  String? _dateOfReceipt;
  String? _companyName;
  String? _processType;
  String? _divisionName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receipt Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Ensures full width
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Date Of Receipt'),
                onChanged: (value) => _dateOfReceipt = value,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Company Name'),
                items: ['Select Company'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _companyName = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Process Type'),
                items: ['Select Process Type'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _processType = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Division Name'),
                items: ['Select Division'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _divisionName = value),
              ),
              SizedBox(height: 20), // Adds spacing before buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      }
                    },
                    child: Text('Submit'),
                  ),
                  SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
