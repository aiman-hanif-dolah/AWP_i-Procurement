import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vendor_model.dart';
import '../providers/vendor_provider.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  File? _selectedFile;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
              ),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (value) =>
                value!.isEmpty ? 'Company name is required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value!.isEmpty ? 'Email is required' : null,
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) =>
                value!.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Upload Document (PDF)'),
              ),
              const SizedBox(height: 20),
              _selectedFile != null
                  ? Text('Selected File: ${_selectedFile!.path.split('/').last}')
                  : const Text('No file selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedFile != null) {
                    final vendor = VendorModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      companyName: _companyNameController.text,
                      email: _emailController.text,
                      phoneNumber: _phoneNumberController.text,
                    );

                    Provider.of<VendorProvider>(context, listen: false)
                        .registerVendor(vendor, _selectedFile!);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vendor registered!')),
                    );

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please complete all fields and upload a file.')),
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
