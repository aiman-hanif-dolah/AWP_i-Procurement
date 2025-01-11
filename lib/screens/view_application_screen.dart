import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/appbar.dart';
import '../widgets/background.dart';

class ViewApplicationScreen extends StatelessWidget {
  const ViewApplicationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? currentVendorId = authProvider.vendorId;

    if (currentVendorId == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'My Applications'),
        body: const Center(child: Text('No vendor ID found. Please log in.')),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'View Applications',
        showBackButton: true,
        showLogout: true,
        backRoute: '/vendor-dashboard',
      ),
      body: Stack(
        children: [
          const AnimatedWebBackground(),
          SafeArea( // Added SafeArea to avoid issues with notches and status bars
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tenders')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading tenders'));
                      }

                      final tenderDocs = snapshot.data?.docs ?? [];
                      if (tenderDocs.isEmpty) {
                        return Center(
                          child: Text(
                            'No tenders available.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white),
                          ).animate().fadeIn(duration: 500.ms),
                        );
                      }

                      return FutureBuilder<List<DocumentSnapshot>>(
                        future: _fetchVendorSubmissions(
                          tenders: tenderDocs,
                          vendorId: currentVendorId,
                        ),
                        builder: (context, submissionSnapshot) {
                          if (submissionSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (submissionSnapshot.hasError) {
                            return const Center(
                                child: Text('Error loading applications'));
                          }

                          final submissions = submissionSnapshot.data ?? [];
                          if (submissions.isEmpty) {
                            return Center(
                              child: Text(
                                'No applications found.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.white),
                              ).animate().fadeIn(duration: 500.ms),
                            );
                          }

                          return ListView.separated( // Changed to ListView.separated
                            padding: const EdgeInsets.all(8.0),
                            itemCount: submissions.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12), // Add spacing between items
                            itemBuilder: (context, index) {
                              final data = submissions[index].data() as Map<String, dynamic>;
                              final tenderId = data['tenderId'] ?? 'N/A';
                              final status = data['status'] ?? 'Pending';
                              final submissionDate = data['timestamp'] == null
                                  ? 'N/A'
                                  : (data['timestamp'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0];

                              IconData statusIcon = Icons.pending_actions;
                              Color statusColor = Colors.grey.shade700;
                              if (status.toUpperCase() == 'APPROVED' ||
                                  status.toUpperCase() == 'ACCEPTED') {
                                statusColor = Colors.green;
                                statusIcon = Icons.check_circle_outline;
                              } else if (status.toUpperCase() == 'REJECTED') {
                                statusColor = Colors.red;
                                statusIcon = Icons.cancel_outlined;
                              }

                              return Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(12),
                                  ),
                                  depth: 2,
                                  intensity: 0.6,
                                  lightSource: LightSource.topLeft,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                child: Padding( // Added padding inside Neumorphic
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        statusIcon,
                                        color: statusColor,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              tenderId,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey.shade900,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Submitted: $submissionDate',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Chip( // Using Chip for a visually distinct status
                                        label: Text(
                                          status,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: statusColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideY(
                                begin: 0.1,
                                duration: 400.ms,
                                curve: Curves.easeInOutQuad,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchVendorSubmissions({
    required List<QueryDocumentSnapshot> tenders,
    required String vendorId,
  }) async {
    final vendorSubmissions = <DocumentSnapshot>[];
    for (final tenderDoc in tenders) {
      final submissionsSnapshot = await FirebaseFirestore.instance
          .collection('tenders')
          .doc(tenderDoc.id)
          .collection('submissions')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      vendorSubmissions.addAll(submissionsSnapshot.docs);
    }
    return vendorSubmissions;
  }
}