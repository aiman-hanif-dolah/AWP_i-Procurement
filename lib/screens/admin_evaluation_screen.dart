import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/submission_model.dart';
import '../models/tender_model.dart';
import '../providers/submission_provider.dart';
import '../providers/tender_provider.dart';

class AdminEvaluationScreen extends StatefulWidget {
  const AdminEvaluationScreen({Key? key}) : super(key: key);

  @override
  State<AdminEvaluationScreen> createState() => _AdminEvaluationScreenState();
}

class _AdminEvaluationScreenState extends State<AdminEvaluationScreen> {
  String? selectedTenderId;

  @override
  Widget build(BuildContext context) {
    final tenderProvider = Provider.of<TenderProvider>(context);
    final submissionProvider = Provider.of<SubmissionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluate Submissions'),
      ),
      body: Column(
        children: [
          // Dropdown for selecting a tender
          StreamBuilder<List<TenderModel>>(
            stream: tenderProvider.fetchTenders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final tenders = snapshot.data ?? [];

              if (tenders.isEmpty) {
                return const Center(
                  child: Text('No tenders available for evaluation.'),
                );
              }

              return DropdownButton<String>(
                hint: const Text('Select a Tender'),
                value: selectedTenderId,
                onChanged: (value) {
                  setState(() {
                    selectedTenderId = value;
                  });
                },
                items: tenders.map((tender) {
                  return DropdownMenuItem(
                    value: tender.id,
                    child: Text(tender.title),
                  );
                }).toList(),
              );
            },
          ),

          // Show submissions for the selected tender
          Expanded(
            child: selectedTenderId == null
                ? const Center(
              child: Text('Please select a tender to view submissions.'),
            )
                : StreamBuilder<List<SubmissionModel>>(
              stream: submissionProvider.fetchSubmissions(selectedTenderId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No submissions found for this tender.'),
                  );
                }

                final submissions = snapshot.data!;
                return ListView.builder(
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final submission = submissions[index];
                    return ListTile(
                      title: Text('Vendor ID: ${submission.vendorId}'),
                      subtitle: Text('Status: ${submission.status}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              _evaluateSubmission(context, submission);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              _rejectSubmission(context, submission);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _evaluateSubmission(BuildContext context, SubmissionModel submission) async {
    try {
      // Fetch the file content from the URL
      final response = await http.get(Uri.parse(submission.fileUrl));

      if (response.statusCode == 200) {
        // Pass the file content to the scoring logic
        final score = _calculateScore(response.bodyBytes);
        await Provider.of<SubmissionProvider>(context, listen: false)
            .evaluateSubmission(submission.id, submission.fileUrl, score);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission evaluated successfully.')),
        );
      } else {
        throw Exception('Failed to fetch file content: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error evaluating submission: $e')),
      );
    }
  }

  void _rejectSubmission(BuildContext context, SubmissionModel submission) {
    Provider.of<SubmissionProvider>(context, listen: false)
        .rejectSubmission(submission.id);
  }

  double _calculateScore(Uint8List fileContent) {
    // Implement your scoring logic using the file content
    // For example:
    return 85.0; // Example placeholder score
  }
}
