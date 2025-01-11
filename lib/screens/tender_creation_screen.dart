// lib/screens/tender_creation_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../providers/tender_provider.dart';
import '../widgets/appbar.dart';
import '../widgets/background.dart';

class TenderCreationScreen extends StatefulWidget {
  const TenderCreationScreen({super.key});

  @override
  State<TenderCreationScreen> createState() => _TenderCreationScreenState();
}

class _TenderCreationScreenState extends State<TenderCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tenderValueController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // Auto-generated submissionId
  late String _submissionId;

  // Default values
  String _tenderType = 'OPEN';
  String _personInCharge = 'Siti';

  DateTime? _startDate;
  DateTime? _endDate;

  String _contractDuration = '';
  String _remainingTime = '';

  // Custom Gradient Decoration
  BoxDecoration _gradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blue.shade200,
          Colors.purple.shade200,
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Generate a simple ID using current timestamp
    _submissionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate =
    isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.blueAccent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text =
          _startDate!.toLocal().toString().split(' ')[0];
        } else {
          _endDate = picked;
          _endDateController.text =
          _endDate!.toLocal().toString().split(' ')[0];
        }

        if (_startDate != null && _endDate != null) {
          final daysDiff = _endDate!.difference(_startDate!).inDays;
          _contractDuration = '$daysDiff days';

          final remaining = _endDate!.difference(DateTime.now()).inDays;
          _remainingTime =
          remaining >= 0 ? '$remaining days remaining' : 'Tender Ended';
        }
      });
    }
  }

  void _showSuccessPopupAndRedirect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade700,
                  Colors.green.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'animations/success.json',
                  height: 120,
                  repeat: false,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Success! 🎉',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tender is successfully created.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/AWP-dashboard',
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Add New Procurement',
        showBackButton: true,
        showLogout: false,
        backRoute: '/AWP-dashboard',
      ),
      body: Stack(
        children: [
          // Gradient background widget
          const AnimatedWebBackground(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Neumorphic(
                    margin: const EdgeInsets.all(20),
                    style: NeumorphicStyle(
                      depth: 5,
                      intensity: 0.8,
                      shadowLightColor: Colors.white,
                      color: Colors.white.withOpacity(0.5),
                      shape: NeumorphicShape.concave,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Lottie.asset(
                              'animations/procurement.json',
                              height: 100,
                              repeat: true,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Add New Procurement 🚀',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // submissionId - auto-generated
                            Neumorphic(
                              style: const NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.9,
                                  color: Colors.white
                              ),
                              child: TextFormField(
                                initialValue: _submissionId,
                                decoration: InputDecoration(
                                  labelText: 'Submission ID (Auto-Generated)',
                                  prefixIcon: const Icon(Icons.assignment),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                                ),
                                enabled: false,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Title
                            Neumorphic(
                              style: const NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.9,
                                  color: Colors.white
                              ),
                              child: TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Tender Title',
                                  prefixIcon: const Icon(Icons.title),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Tender Title is required'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Tender type
                            Neumorphic(
                              style: const NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.9,
                                  color: Colors.white
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _tenderType,
                                items: ['OPEN', 'CLOSE', 'DIRECT'].map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text('$type 🔄'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _tenderType = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Tender Type',
                                  prefixIcon: const Icon(Icons.category),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Person-in-Charge
                            Neumorphic(
                              style: const NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.9,
                                  color: Colors.white
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _personInCharge,
                                items: ['Siti', 'Ali'].map((person) {
                                  return DropdownMenuItem(
                                    value: person,
                                    child: Text('$person 👤'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _personInCharge = value!;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Person-in-Charge',
                                  prefixIcon: const Icon(Icons.person),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Description
                            Neumorphic(
                              style: const NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.9,
                                  color: Colors.white
                              ),
                              child: TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description ✍️',
                                  prefixIcon: const Icon(Icons.description),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                                ),
                                maxLines: 4,
                                validator: (value) => value!.isEmpty
                                    ? 'Description is required'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Tender Value
                            Neumorphic(
                              style: const NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.9,
                                  color: Colors.white
                              ),
                              child: TextFormField(
                                controller: _tenderValueController,
                                decoration: InputDecoration(
                                  labelText: 'Tender Value (RM)',
                                  prefixIcon: const Icon(Icons.attach_money),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) => value!.isEmpty
                                    ? 'Tender Value is required'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Start Date field
                            Neumorphic(
                              style: const NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.9,
                                  color: Colors.white
                              ),
                              child: TextFormField(
                                controller: _startDateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Start Date',
                                  prefixIcon: const Icon(Icons.date_range),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                                ),
                                onTap: () => _selectDate(context, true),
                                validator: (_) => _startDate == null
                                    ? 'Please pick a start date'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // End Date field
                            Neumorphic(
                              style: const NeumorphicStyle(
                                  depth: -2,
                                  intensity: 0.9,
                                  color: Colors.white
                              ),
                              child: TextFormField(
                                controller: _endDateController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'End Date',
                                  prefixIcon: const Icon(Icons.event),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                                ),
                                onTap: () => _selectDate(context, false),
                                validator: (_) => _endDate == null
                                    ? 'Please pick an end date'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Dates summary card
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: _startDate != null && _endDate != null
                                  ? Neumorphic(
                                style: const NeumorphicStyle(
                                    depth: 5,
                                    intensity: 0.8,
                                    shadowLightColor: Colors.white,
                                    color: Colors.white,
                                    shape: NeumorphicShape.concave
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // Start Date Row
                                      Row(
                                        children: [
                                          Icon(Icons.date_range,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Start Date:',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _startDate!
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // End Date Row
                                      Row(
                                        children: [
                                          Icon(Icons.event,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 8),
                                          Text(
                                            'End Date:',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _endDate!
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Contract Duration Row
                                      Row(
                                        children: [
                                          Icon(Icons.timer,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Contract Duration:',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _contractDuration,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Remaining Time Row
                                      Row(
                                        children: [
                                          Icon(Icons.hourglass_bottom,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              _remainingTime,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  : Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 36,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No date range selected ⏳',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Submit button
                            NeumorphicButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate() &&
                                    _startDate != null &&
                                    _endDate != null) {
                                  Provider.of<TenderProvider>(context,
                                      listen: false)
                                      .createTender({
                                    'submissionId': _submissionId,
                                    'title': _titleController.text,
                                    'tenderType': _tenderType,
                                    'personInCharge': _personInCharge,
                                    'description': _descriptionController.text,
                                    'tenderValue': _tenderValueController.text,
                                    'startDate': _startDate,
                                    'endDate': _endDate,
                                    'status': 'PENDING', // Initial status
                                  });

                                  _showSuccessPopupAndRedirect();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please complete all fields and select a date range. ❗',
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                                  depth: 4,
                                  color: Colors.green.shade700
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                child: Text(
                                  'Add Procurement ✅',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
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