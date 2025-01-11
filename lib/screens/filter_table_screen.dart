import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your custom theme and widgets (update paths as needed)
import '../services/theme.dart';
import '../widgets/appbar.dart';
import '../widgets/background.dart';
import '../widgets/container.dart';

class FilterTableScreen extends StatefulWidget {
  final String tenderId;
  final String fileUrl;
  final String? backRoute;

  const FilterTableScreen({
    Key? key,
    required this.tenderId,
    required this.fileUrl,
    this.backRoute,
  }) : super(key: key);

  @override
  State<FilterTableScreen> createState() => _FilterTableScreenState();
}

class _FilterTableScreenState extends State<FilterTableScreen> {
  // We manage only ONE doc (single submission)
  Map<String, dynamic> _filterRow = {};
  String? _docId;
  bool isProcessing = false;
  Timer? _debounce;
  late SharedPreferences _prefs;

  // Add a ScrollController to fix the "Scrollbar has no ScrollPosition" error
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _loadOrCreateSingleSubmission();
  }

  // 0) Initialize shared_preferences
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 1) Load the *first* submission doc or create one
  Future<void> _loadOrCreateSingleSubmission() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tenders')
          .doc(widget.tenderId)
          .collection('submissions')
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        // No doc => create new
        final docRef = await _createNewSubmissionDoc();
        _docId = docRef.id;
      } else {
        // Use the first doc
        final doc = snap.docs.first;
        _docId = doc.id;
        final data = doc.data();
        setState(() {
          _filterRow = {
            'id': _docId,
            'procurementId': widget.tenderId,
            'chapter': data['chapter'] ?? '',
            'chapterName': data['chapterName'] ?? '',
            'info': data['info'] ?? 0,
            'crq': data['crq'] ?? 0,
            'mrq': data['mrq'] ?? 0,
            'req': data['req'] ?? 0,
            'irq': data['irq'] ?? 0,
            'fields': data['fields'] ?? {},
            'evaluationResult': data['evaluationResult'] ?? '',
            'approvalStatus': data['status'] ?? 'PENDING',
            'status': data['status'] ?? 'PENDING',
            'fileUrl': data['fileUrl'] ?? widget.fileUrl,
          };
        });
      }
      _loadLocalData();
      _checkIfEvaluationComplete();
    } catch (e) {
      debugPrint('>>> _loadOrCreateSingleSubmission error: $e');
      _showCustomNotification('Error loading submission: $e', isError: true);
    }
  }

  // 2) Create brand-new doc
  Future<DocumentReference> _createNewSubmissionDoc() async {
    final docRef = FirebaseFirestore.instance
        .collection('tenders')
        .doc(widget.tenderId)
        .collection('submissions')
        .doc();

    final newData = {
      'chapter': '',
      'chapterName': '',
      'info': 0,
      'crq': 0,
      'mrq': 0,
      'req': 0,
      'irq': 0,
      'fields': {},
      'evaluationResult': '',
      'status': 'PENDING',
      'fileUrl': widget.fileUrl,
      'submissionId': docRef.id,
    };

    await docRef.set(newData);
    setState(() {
      _filterRow = {
        'id': docRef.id,
        'procurementId': widget.tenderId,
        'chapter': '',
        'chapterName': '',
        'info': 0,
        'crq': 0,
        'mrq': 0,
        'req': 0,
        'irq': 0,
        'fields': {},
        'evaluationResult': '',
        'approvalStatus': 'PENDING',
        'status': 'PENDING',
        'fileUrl': widget.fileUrl,
      };
    });
    _saveLocalData();
    _showCustomNotification('New single submission doc created.');
    return docRef;
  }

  // Save/Load local
  void _loadLocalData() {
    if (_docId == null) return;
    final key = 'filterRow_${widget.tenderId}_$_docId';
    final savedJson = _prefs.getString(key);
    if (savedJson != null) {
      final localMap = jsonDecode(savedJson) as Map<String, dynamic>;
      setState(() {
        _filterRow.addAll(localMap);
      });
    }
  }

  Future<void> _saveLocalData() async {
    if (_docId == null) return;
    final key = 'filterRow_${widget.tenderId}_$_docId';
    await _prefs.setString(key, jsonEncode(_filterRow));
  }

  // Check if doc is fully evaluated
  void _checkIfEvaluationComplete() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.lightTheme.primaryColor;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        title: 'Procurement Dashboard',
        showBackButton: true,
        showLogout: true,
        backRoute: widget.backRoute,
      ),
      body: Stack(
        children: [
          const AnimatedWebBackground(),
          // We wrap our main content in a Scrollbar + SingleChildScrollView
          // with the same controller => prevents the "no scroll position" error
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,   // or false
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: _buildMainContent(context, primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Color primaryColor) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Lottie.asset('animations/procurement.json',
              // fallback to ignoreErrors: true if needed
              errorBuilder: (context, error, stackTrace) {
                return const Text('Animation failed to load');
              }),
        ),
        const SizedBox(height: 16),

        // Glassmorphic instructions
        GlassmorphicContainer(
          width: double.infinity,
          height: 130,
          borderRadius: 20,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome! 👋',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• This screen handles one submission doc.\n'
                        '• Edit fields, press "Process".\n'
                        '• Approve or Reject when done.\n'
                        '• If you see pointer assertion in debug mode, reduce re-renders.',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Card with single data row
        Neumorphic(
          style: NeumorphicStyle(
            shape: NeumorphicShape.flat,
            boxShape:
            NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
            depth: 5,
            intensity: 0.8,
            lightSource: LightSource.topLeft,
            color: Colors.grey[200],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubmissionStatus(),
                  const SizedBox(height: 8),
                  _buildSingleDataTable(primaryColor),
                  const SizedBox(height: 16),

                  // If pending, show Approve/Reject
                  if (_docId != null &&
                      _filterRow.isNotEmpty &&
                      (_filterRow['approvalStatus'] ?? 'PENDING') ==
                          'PENDING') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline,
                              size: 16, color: Colors.white),
                          label: const Text('Approve Submission',
                              style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _approveSingleDoc();
                          },
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.cancel,
                              size: 16, color: Colors.white),
                          label: const Text('Reject Submission',
                              style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _rejectSingleDoc();
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Processing indicator
                  if (isProcessing)
                    Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Show status outside the table
  Widget _buildSubmissionStatus() {
    if (_docId == null || _filterRow.isEmpty) {
      return const Text(
        'Submission Status: Loading...',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    }
    final status = (_filterRow['approvalStatus'] ?? 'PENDING').toString();
    Color color = Colors.orange;
    if (status.toUpperCase().contains('APPROVE') ||
        status.toUpperCase().contains('ACCEPT')) {
      color = Colors.green;
    } else if (status.toUpperCase().contains('REJECT')) {
      color = Colors.red;
    }
    return Text(
      'Submission Status: $status',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
    );
  }

  // We no longer display 'Status' in the table; it's above
  Widget _buildSingleDataTable(Color primaryColor) {
    if (_docId == null || _filterRow.isEmpty) {
      return const Center(child: Text('Loading single submission...'));
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(primaryColor),
          headingTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          dataRowColor: WidgetStateProperty.all(Colors.white),
          dataTextStyle: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
          columns: const [
            DataColumn(label: Text('Chapter')),
            DataColumn(label: Text('Chapter Name')),
            DataColumn(label: Text('INFO Count')),
            DataColumn(label: Text('CRQ Count')),
            DataColumn(label: Text('MRQ Count')),
            DataColumn(label: Text('REQ Count')),
            DataColumn(label: Text('IRQ Count')),
            DataColumn(label: Text('Action')),
          ],
          rows: [
            DataRow(
              cells: [
                // CHAPTER
                DataCell(
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      initialValue: _filterRow['chapter'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        border: UnderlineInputBorder(),
                        hintText: 'Chapter',
                        hintStyle: TextStyle(color: Colors.black38),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filterRow['chapter'] = value;
                        });
                        _saveLocalData();

                        // Debounce to reduce re-renders
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 300), () {
                          _fetchAndProcessSingleSubmission(value);
                        });
                      },
                    ),
                  ),
                ),

                // CHAPTER NAME
                DataCell(
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      initialValue: _filterRow['chapterName'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        border: UnderlineInputBorder(),
                        hintText: 'Chapter Name',
                        hintStyle: TextStyle(color: Colors.black38),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filterRow['chapterName'] = value;
                        });
                        _saveLocalData();

                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 300), () {
                          _fetchAndProcessSingleSubmission(value);
                        });
                      },
                    ),
                  ),
                ),

                // INFO / CRQ / MRQ / REQ / IRQ
                DataCell(Text('${_filterRow['info'] ?? 0}')),
                DataCell(Text('${_filterRow['crq'] ?? 0}')),
                DataCell(Text('${_filterRow['mrq'] ?? 0}')),
                DataCell(Text('${_filterRow['req'] ?? 0}')),
                DataCell(Text('${_filterRow['irq'] ?? 0}')),

                // ACTION => "Process"
                DataCell(
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_fill,
                        size: 16, color: Colors.white),
                    label: const Text('Process', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _processSingleRow();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 3) Parse Excel for the single row
  Future<void> _fetchAndProcessSingleSubmission(String chapterName) async {
    final fileUrl = _filterRow['fileUrl'] ?? widget.fileUrl;
    if (fileUrl.isEmpty) {
      debugPrint('>>> No fileUrl. Skipping Excel parse.');
      return;
    }

    try {
      setState(() => isProcessing = true);
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch file. Status: ${response.statusCode}');
      }
      final bytes = response.bodyBytes;
      final ex.Excel excel = ex.Excel.decodeBytes(bytes);

      final sheet = excel.tables[chapterName.trim()];
      if (sheet == null) {
        throw Exception('Sheet "$chapterName" not found in Excel.');
      }

      final fieldResults = {
        'INFO': {'count': 0, 'values': <String>[]},
        'CRQ': {'count': 0, 'values': <String>[]},
        'MRQ': {'count': 0, 'values': <String>[]},
        'REQ': {'count': 0, 'values': <String>[]},
        'IRQ': {'count': 0, 'values': <String>[]},
      };

      for (var row in sheet.rows) {
        for (int i = 0; i < row.length; i++) {
          final cellValue = row[i]?.value?.toString().trim().toUpperCase() ?? '';
          if (fieldResults.containsKey(cellValue)) {
            if (i + 1 < row.length) {
              final adjacentValue =
                  row[i + 1]?.value?.toString().trim() ?? '';
              fieldResults[cellValue]!['count'] =
                  (fieldResults[cellValue]!['count'] as int) + 1;
              (fieldResults[cellValue]!['values'] as List<String>)
                  .add(adjacentValue);
            }
          }
        }
      }

      setState(() {
        _filterRow['fields'] = fieldResults;
        _filterRow['info'] = fieldResults['INFO']!['count'];
        _filterRow['crq'] = fieldResults['CRQ']!['count'];
        _filterRow['mrq'] = fieldResults['MRQ']!['count'];
        _filterRow['req'] = fieldResults['REQ']!['count'];
        _filterRow['irq'] = fieldResults['IRQ']!['count'];
      });

      _saveLocalData();
      _showCustomNotification('Filter applied! ✅');
    } catch (e) {
      debugPrint('>>> _fetchAndProcessSingleSubmission Error: $e');
      _showCustomNotification('Error: $e', isError: true);
    } finally {
      setState(() {
        isProcessing = false;
        _checkIfEvaluationComplete();
      });
    }
  }

  /// 4) "Process" row using ChatGPT
  Future<void> _processSingleRow() async {
    final fieldData = _filterRow['fields'] as Map<String, dynamic>?;
    if (fieldData == null) {
      _showCustomNotification('No field data to process.', isError: true);
      return;
    }
    final prompt = _generateProcurementPrompt(fieldData);

    const apiKey =
        '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';
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content':
          'You are a knowledgeable procurement expert analyzing a single submission.'
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'max_tokens': 150,
      'temperature': 0.7,
    });

    try {
      final response = await http
          .post(Uri.parse(apiUrl), headers: headers, body: body)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = jsonResponse['choices'][0]['message']['content'].trim();
        setState(() {
          _filterRow['evaluationResult'] = result;
        });
        _saveLocalData();
        _showEvaluationDialog(result);
      } else {
        setState(() {
          _filterRow['evaluationResult'] = 'Evaluation failed.';
        });
        _showCustomNotification(
            'Evaluation failed: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      setState(() {
        _filterRow['evaluationResult'] = 'Error: $e';
      });
      _showCustomNotification('Error: $e', isError: true);
    } finally {
      _checkIfEvaluationComplete();
    }
  }

  /// 5) Approve doc
  Future<void> _approveSingleDoc() async {
    if (_docId == null) return;
    try {
      final docRef = FirebaseFirestore.instance
          .collection('tenders')
          .doc(widget.tenderId)
          .collection('submissions')
          .doc(_docId);

      final batch = FirebaseFirestore.instance.batch();
      batch.update(docRef, {'status': 'ACCEPTED'});

      // Optionally also accept the entire tender
      final tenderDocRef =
      FirebaseFirestore.instance.collection('tenders').doc(widget.tenderId);
      batch.update(tenderDocRef, {'status': 'ACCEPTED'});

      await batch.commit();

      setState(() {
        _filterRow['approvalStatus'] = 'ACCEPTED';
        _filterRow['status'] = 'ACCEPTED';
      });
      _saveLocalData();
      _showCustomNotification('Submission approved! ✅');
    } catch (e) {
      _showCustomNotification('Approval error: $e', isError: true);
    }
  }

  /// 6) Reject doc
  Future<void> _rejectSingleDoc() async {
    if (_docId == null) return;
    try {
      final docRef = FirebaseFirestore.instance
          .collection('tenders')
          .doc(widget.tenderId)
          .collection('submissions')
          .doc(_docId);

      final batch = FirebaseFirestore.instance.batch();
      batch.update(docRef, {'status': 'REJECTED'});

      // If you'd like to also set the tender doc itself to REJECTED, do it here:
      // final tenderDocRef = FirebaseFirestore.instance
      //     .collection('tenders')
      //     .doc(widget.tenderId);
      // batch.update(tenderDocRef, {'status': 'REJECTED'});

      await batch.commit();

      setState(() {
        _filterRow['approvalStatus'] = 'REJECTED';
        _filterRow['status'] = 'REJECTED';
      });
      _saveLocalData();
      _showCustomNotification('Submission rejected. ❌');
    } catch (e) {
      _showCustomNotification('Reject error: $e', isError: true);
    }
  }

  // Prompt generator
  String _generateProcurementPrompt(Map<String, dynamic> fieldData) {
    String prompt = '''
You are an expert procurement analyst. Analyze the submission below and evaluate its quality.

Submission Data:
''';
    fieldData.forEach((key, details) {
      final count = details['count'];
      final values = (details['values'] as List).join(', ');
      prompt += '$key: Found $count times. Details: $values\n';
    });
    return prompt;
  }

  void _showEvaluationDialog(String evaluation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('AI Evaluation Result 🤖'),
          content: SingleChildScrollView(child: Text(evaluation)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showCustomNotification(String message, {bool isError = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Flushbar(
        message: message,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: isError ? Colors.redAccent : Colors.blueAccent,
        flushbarStyle: FlushbarStyle.FLOATING,
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.all(12),
        icon: const Icon(Icons.info_outline, color: Colors.white),
        dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        maxWidth: 250,
      ).show(context);
    });
  }
}