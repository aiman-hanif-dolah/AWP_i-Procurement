import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';
import '../models/submission_model.dart';
import '../models/tender_model.dart';
import '../providers/submission_provider.dart';
import '../providers/tender_provider.dart';
import '../widgets/appbar.dart';
import '../widgets/background.dart';
import 'filter_table_screen.dart';

class AWPEvaluationScreen extends StatefulWidget {
  const AWPEvaluationScreen({Key? key}) : super(key: key);

  @override
  State<AWPEvaluationScreen> createState() => _AWPEvaluationScreenState();
}

class _AWPEvaluationScreenState extends State<AWPEvaluationScreen> {
  TenderModel? selectedTender;
  // This field will hold the evaluation message returned from the FilterTableScreen.
  String evaluationMessage = '';

  @override
  Widget build(BuildContext context) {
    // Retrieve providers.
    final tenderProvider = Provider.of<TenderProvider>(context);
    final submissionProvider = Provider.of<SubmissionProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Evaluate Submissions',
        showBackButton: true,
        showLogout: true,
          backRoute: '/AWP-dashboard'
      ),
      body: Stack(
        children: [
          const AnimatedWebBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lottie banner in a centered container.
                Center(
                  child: SizedBox(
                    height: 120,
                    child: Lottie.asset('animations/procurement.json'),
                  ),
                ),
                const SizedBox(height: 24),
                // Glassmorphic container with instructions.
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 120,
                  borderRadius: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 13, color: Colors.white),
                        children: [
                          TextSpan(
                            text: 'Welcome! 👋\n',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                            'Tap on a tender card to view its submissions.\n'
                                'Tap on a submission for AI evaluation.\n'
                                'Enjoy the modern neumorphic & glassmorphic UI!',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Tender selection header.
                Text(
                  'Select a Tender for Evaluation',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildTenderGrid(tenderProvider),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // If a tender is selected, show its submissions.
                if (selectedTender != null) ...[
                  Text(
                    'Submissions for ${selectedTender!.title}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 24),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildSubmissionGrid(submissionProvider),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
                if (evaluationMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        depth: 4,
                        intensity: 0.8,
                        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Evaluation:\n$evaluationMessage',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a grid of tender cards wrapped in Neumorphic styling.
  Widget _buildTenderGrid(TenderProvider tenderProvider) {
    return StreamBuilder<List<TenderModel>>(
      stream: tenderProvider.fetchTenders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }
        final tenders = snapshot.data ?? [];
        if (tenders.isEmpty) {
          return Center(
            child: Text(
              'No tenders available for evaluation.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          );
        }
        // Use Masonry grid with 3 columns.
        return MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: tenders.length,
          itemBuilder: (context, index) {
            final tender = tenders[index];
            final bool isSelected = selectedTender?.submissionId == tender.submissionId;
            return NeumorphicButton(
              onPressed: () {
                setState(() {
                  selectedTender = tender;
                  evaluationMessage = '';
                });
              },
              style: NeumorphicStyle(
                depth: isSelected ? -8 : 8,
                intensity: 0.65,
                color: isSelected ? Colors.deepPurple: Colors.deepPurpleAccent,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
              ),
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(16),
              pressed: isSelected,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tender.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tender.description ?? 'No description',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Builds a grid of submission cards with Neumorphic design.
  Widget _buildSubmissionGrid(SubmissionProvider submissionProvider) {
    return StreamBuilder<List<SubmissionModel>>(
      stream: submissionProvider.fetchSubmissions(selectedTender!.submissionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }
        final submissions = snapshot.data ?? [];
        if (submissions.isEmpty) {
          return Center(
            child: Text(
              'No submissions found for this tender.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          );
        }
        return MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: submissions.length,
          itemBuilder: (context, index) {
            final submission = submissions[index];
            return NeumorphicButton(
              onPressed: () {
                _openFilterTableForSubmission(submission);
              },
              style: NeumorphicStyle(
                depth: 8,
                intensity: 0.65,
                color: Colors.orange.shade200,
                boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
              ),
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vendor: ${submission.vendorId}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${submission.status}',
                    style: TextStyle(
                      fontSize: 12,
                      color: submission.status.toLowerCase().contains('pending')
                          ? Colors.red
                          : Colors.lightGreenAccent,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Navigates to the FilterTableScreen for the tapped submission.
  void _openFilterTableForSubmission(SubmissionModel submission) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterTableScreen(
          tenderId: selectedTender!.submissionId,
          fileUrl: submission.fileUrl,
          backRoute: '/AWP-evaluation', // returns here when done
        ),
      ),
    );

    // If the FilterTableScreen returns an evaluation message, update state.
    if (result != null && result.containsKey('evaluationMessage')) {
      if (!mounted) return;
      setState(() {
        evaluationMessage = result['evaluationMessage'];
      });
    }
  }
}

/// A custom glassmorphic container using BackdropFilter for a frosted glass effect.
class GlassmorphicContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget child;

  const GlassmorphicContainer({
    Key? key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: child,
        ),
      ),
    );
  }
}
