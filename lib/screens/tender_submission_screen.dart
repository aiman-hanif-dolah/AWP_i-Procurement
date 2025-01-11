import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart'; // for Timestamp
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart'; // for formatting dates
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/submission_provider.dart';
import '../providers/tender_provider.dart';
import '../widgets/appbar.dart';
import '../widgets/background.dart';

class TenderSubmissionScreen extends StatefulWidget {
  const TenderSubmissionScreen({Key? key}) : super(key: key);

  @override
  State<TenderSubmissionScreen> createState() => _TenderSubmissionScreenState();
}

class _TenderSubmissionScreenState extends State<TenderSubmissionScreen> {
  String? tenderId;
  File? _selectedFile;
  Map<String, dynamic>? tenderDetails;
  bool isLoading = true;
  String? errorMessage;
  String? _fileName; // To store the file name
  Uint8List? _fileBytes; // To store file bytes (for web)

  // List of TextEditingControllers for TEC Member Registration.
  final List<TextEditingController> _tecMemberControllers = [
    TextEditingController()
  ];

  @override
  void initState() {
    super.initState();
    _restoreSelectedTender();
  }

  Future<void> _restoreSelectedTender() async {
    final prefs = await SharedPreferences.getInstance();
    tenderId = prefs.getString('selectedTenderId');

    if (tenderId != null) {
      await _loadTenderDetails();
    } else {
      setState(() {
        errorMessage = 'No tender selected. Please go back and select a tender.';
        isLoading = false;
      });
    }
  }

  Future<void> _loadTenderDetails() async {
    try {
      final tenderProvider = Provider.of<TenderProvider>(context, listen: false);
      final tender = await tenderProvider.fetchTenderById(tenderId!);

      setState(() {
        tenderDetails = tender;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load tender details. Please try again.';
        isLoading = false;
      });
    }
  }

  /// Convert Timestamps or other fields to friendlier strings
  String _formatValue(dynamic value) {
    if (value is Timestamp) {
      final dateTime = value.toDate();
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
    return value?.toString() ?? '';
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null) {
      if (kIsWeb) {
        // Handle file bytes for web
        if (result.files.single.bytes != null) {
          setState(() {
            _selectedFile = null;
            _fileName = result.files.single.name;
            _fileBytes = result.files.single.bytes!;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid file selected!')),
          );
        }
      } else {
        // Handle file path for mobile/desktop
        if (result.files.single.path != null) {
          setState(() {
            _selectedFile = File(result.files.single.path!);
            _fileName = result.files.single.name;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid file selected!')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
  }

  Future<void> _submitFile() async {
    if ((tenderId == null) || (_selectedFile == null && _fileBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }

    try {
      // Retrieve vendor ID from AuthProvider.
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vendorId = authProvider.currentUser?.email ?? '';

      if (vendorId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vendor ID not found.')),
        );
        return;
      }

      // Build submission data
      final submissionData = {
        'vendorId': vendorId,
        'timestamp': DateTime.now(),
        'tecMembers': _tecMemberControllers
            .map((controller) => controller.text)
            .toList(),
        ...?tenderDetails,
      };

      final submissionProvider =
      Provider.of<SubmissionProvider>(context, listen: false);

      // Web upload
      if (kIsWeb) {
        await submissionProvider.submitTenderWeb(
          tenderId!,
          _fileBytes!,
          _fileName!,
          submissionData,
        );
      } else {
        // Mobile/desktop upload
        await submissionProvider.submitTender(
          tenderId!,
          _selectedFile!,
          submissionData,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tender submitted successfully!')),
      );

      // Navigate away...
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/vendor-dashboard',
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting tender: $e')),
      );
    }
  }

  void _addTecMember() {
    setState(() {
      _tecMemberControllers.add(TextEditingController());
    });
  }

  void _removeTecMember() {
    if (_tecMemberControllers.length > 1) {
      setState(() {
        _tecMemberControllers.removeLast();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _tecMemberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<Widget> _buildTecMemberFields() {
    return List<Widget>.generate(_tecMemberControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          controller: _tecMemberControllers[index],
          decoration: InputDecoration(
            labelText: 'Name ${index + 1}',
            hintText: 'TEC Member ${index + 1}',
            prefixIcon: const Icon(Icons.person),
          ),
        ),
      );
    });
  }

  IconData _getIconForField(String fieldKey) {
    switch (fieldKey) {
      case 'description':
        return Icons.description;
      case 'title':
        return Icons.title;
      case 'tenderValue':
        return Icons.attach_money;
      case 'startDate':
      case 'endDate':
        return Icons.date_range;
      case 'personInCharge':
        return Icons.person;
      case 'status':
        return Icons.flag;
      case 'procurementId':
        return Icons.numbers;
      default:
        return Icons.info;
    }
  }

  String _formatFieldKey(String fieldKey) {
    // Convert e.g. "tenderValue" -> "Tender Value"
    return fieldKey
        .replaceAll(RegExp(r'[_\$]'), ' ')
        .replaceAllMapped(
      RegExp(r'(^[a-z]|(?<=\s)[a-z])'),
          (match) => match.group(0)!.toUpperCase(),
    )
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Submit Tender',
        showBackButton: true,
        showLogout: true,
      ),
      body: Stack(
        children: [
          // Reuse your animated background
          const AnimatedWebBackground(),

          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            )
          else
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                // Constrain the max width for a more pleasing layout
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: // Outer Card with gradient (colorful, just like AWP/Vendor)
                  Container(
                    decoration: BoxDecoration(
                      // Reuse a gradient approach from your AWP dashboard style:
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.8),
                          Colors.lightBlueAccent.withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      // Put a semi-transparent white card inside for a neumorphic effect
                      color: Colors.white.withOpacity(0.85),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tender Submission',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Review tender info, add TEC members, and upload your .xlsx file.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[800]),
                            ),
                            const SizedBox(height: 24),

                            // TENDER INFO
                            Text(
                              'Tender Info',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Divider(thickness: 2),
                            const SizedBox(height: 16),

                            if (tenderDetails == null)
                              const Text('No details found.')
                            else
                              MasonryGridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tenderDetails!.length,
                                itemBuilder: (context, index) {
                                  final entry = tenderDetails!.entries.toList()[index];
                                  final key = entry.key;
                                  final value = entry.value;
                                  // Hide certain fields
                                  if (key == 'submissionId' || key == 'isOpen') {
                                    return const SizedBox.shrink();
                                  }

                                  final displayedKey = _formatFieldKey(key);
                                  final displayedValue = _formatValue(value);

                                  return Container(
                                    decoration: BoxDecoration(
                                      // A slight neumorphic vibe for each field
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          _getIconForField(key),
                                          color: Colors.blueAccent,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          displayedKey,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(displayedValue),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 24),

                            // TEC MEMBERS
                            Text(
                              'TEC Member Registration',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Divider(thickness: 2),
                            const SizedBox(height: 16),
                            ..._buildTecMemberFields(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _addTecMember,
                                  icon: const Icon(Icons.add, color: Colors.white,),
                                  label: const Text('Add'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _removeTecMember,
                                  icon: const Icon(Icons.remove, color: Colors.white),
                                  label: const Text('Remove'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pinkAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // UPLOAD SUBMISSION
                            Text(
                              'Upload Submission',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Divider(thickness: 2),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _pickFile,
                              icon: const Icon(Icons.upload_file, color: Colors.white,),
                              label: const Text('Upload Excel File'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            if (_fileName != null || _selectedFile != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Selected File: ${_fileName ?? _selectedFile!.path.split('/').last}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // SUBMIT BUTTON
                            ElevatedButton.icon(
                              icon: const Icon(Icons.file_upload, color: Colors.white,),
                              onPressed: _submitFile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(horizontal: 50),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              label: const Text('Submit'),
                            ),
                          ],
                        ),
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
}
