// Updated version to dynamically handle parameters without hardcoded constructor passing.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/submission_provider.dart';
// Assuming for user info

class TenderSubmissionScreen extends StatefulWidget {
  const TenderSubmissionScreen({Key? key}) : super(key: key);

  @override
  State<TenderSubmissionScreen> createState() => _TenderSubmissionScreenState();
}

class _TenderSubmissionScreenState extends State<TenderSubmissionScreen> {
  String? tenderId;
  File? _selectedFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch tenderId dynamically via route arguments or shared state
    tenderId = ModalRoute.of(context)?.settings.arguments as String?;
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xslx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _submitFile() async {
    if (_selectedFile == null || tenderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file and ensure tender ID is available.')),
      );
      return;
    }

    try {
      // Construct the submission data with necessary metadata
      final submissionData = {
        'vendorId': 'exampleVendorId', // Replace with actual vendor ID
        'timestamp': DateTime.now(),
      };

      await Provider.of<SubmissionProvider>(context, listen: false).submitTender(
        tenderId!,
        _selectedFile!,
        submissionData, // Third argument
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tender submitted successfully.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Tender')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Upload Tender File (PDF)'),
            ),
            const SizedBox(height: 20),
            _selectedFile != null
                ? Text('Selected File: ${_selectedFile!.path.split('/').last}')
                : const Text('No file selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFile,
              child: const Text('Submit Tender'),
            ),
          ],
        ),
      ),
    );
  }
}
