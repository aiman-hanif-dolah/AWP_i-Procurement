import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pie_chart/pie_chart.dart';

import '../providers/tender_provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/appbar.dart';
import '../widgets/background.dart';

class AWPReportsScreen extends StatelessWidget {
  const AWPReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    Provider.of<TenderProvider>(context, listen: false);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'AWP Reports',
        showBackButton: true,
        showLogout: true,
          backRoute: '/AWP-dashboard'
      ),
      body: Stack(
        children: [
          const AnimatedWebBackground(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --------------------------------------------------
                  // 1) FutureBuilder for the overall DB stats (Pie Chart)
                  //    (users, tenders, submissions)
                  // --------------------------------------------------
                  FutureBuilder<Map<String, int>>(
                    future: fetchDatabaseStats(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Error loading database stats: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }

                      final stats = snapshot.data ?? {
                        'users': 0,
                        'tenders': 0,
                        'submissions': 0,
                      };

                      // Convert to double for the pie chart
                      final dataMap = {
                        'Users': stats['users']!.toDouble(),
                        'Tenders': stats['tenders']!.toDouble(),
                        'Submissions': stats['submissions']!.toDouble(),
                      };

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        color: Colors.white.withOpacity(0.8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Database Overview',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              PieChart(
                                dataMap: dataMap,
                                animationDuration:
                                const Duration(milliseconds: 800),
                                chartRadius: 150,
                                chartType: ChartType.disc,
                                legendOptions: const LegendOptions(
                                  legendPosition: LegendPosition.right,
                                ),
                                chartValuesOptions: const ChartValuesOptions(
                                  showChartValuesInPercentage: true,
                                  showChartValuesOutside: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // --------------------------------------------------
                  // 2) FutureBuilder for APPROVED vs. PENDING Statuses
                  // --------------------------------------------------
                  FutureBuilder<Map<String, int>>(
                    future: fetchApprovalStats(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Error loading approval stats: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }

                      final approvalStats = snapshot.data ?? {
                        'APPROVED': 0,
                        'PENDING': 0,
                      };

                      final totalApproved =
                      approvalStats['APPROVED']!.toDouble();
                      final totalPending =
                      approvalStats['PENDING']!.toDouble();

                      // If you have other statuses, consider adding them here
                      final statusMap = {
                        'APPROVED': totalApproved,
                        'PENDING': totalPending,
                      };

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        color: Colors.white.withOpacity(0.8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Submission Status Overview',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              PieChart(
                                dataMap: statusMap,
                                animationDuration:
                                const Duration(milliseconds: 800),
                                chartRadius: 150,
                                chartType: ChartType.disc,
                                legendOptions: const LegendOptions(
                                  legendPosition: LegendPosition.right,
                                ),
                                chartValuesOptions: const ChartValuesOptions(
                                  showChartValuesInPercentage: true,
                                  showChartValuesOutside: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // --------------------------------------------------
                  // 3) FutureBuilder for the Vendor Report
                  //    (we remove the Lottie animation and TENDER REPORT)
                  // --------------------------------------------------
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: vendorProvider.fetchVendorsReport(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading vendor reports: ${snapshot.error}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        );
                      }

                      final vendorReport = snapshot.data ?? [];

                      return _buildReportSection(
                        context,
                        title: 'Vendor Report',
                        reportData: vendorReport,
                        colors: [Colors.pinkAccent, Colors.orangeAccent],
                        icon: Icons.people_alt,
                        emptyMessage: '',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // Renders a Masonry grid of data items (like your Vendor Report)
  // ------------------------------------------------------------------------
  Widget _buildReportSection(
      BuildContext context, {
        required String title,
        required List<Map<String, dynamic>> reportData,
        required List<Color> colors,
        required IconData icon,
        required String emptyMessage,
      }) {
    if (reportData.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ).animate().fadeIn(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 12.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().slide(begin: const Offset(-0.1, 0)).fadeIn(),
        ),

        // Masonry Grid
        MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: reportData.length,
          itemBuilder: (context, index) {
            final data = reportData[index];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 32),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['title'] ??
                              data['companyName'] ??
                              'Unknown Vendor',
                          style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['status'] ?? 'No status available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ).animate().slide(begin: const Offset(0.1, 0)).fadeIn(),
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------------------
  // This method fetches total counts of users, tenders, and submissions
  // ------------------------------------------------------------------------
  Future<Map<String, int>> fetchDatabaseStats() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      // Count user docs
      final usersSnap = await _firestore.collection('users').get();
      final totalUsers = usersSnap.size;

      // Count tender docs
      final tendersSnap = await _firestore.collection('tenders').get();
      final totalTenders = tendersSnap.size;

      // Sum up total submissions across all tenders
      int totalSubmissions = 0;
      for (var tenderDoc in tendersSnap.docs) {
        final submissionsSnap =
        await tenderDoc.reference.collection('submissions').get();
        totalSubmissions += submissionsSnap.size;
      }

      return {
        'users': totalUsers,
        'tenders': totalTenders,
        'submissions': totalSubmissions,
      };
    } catch (e) {
      throw Exception('Failed to fetch DB stats: $e');
    }
  }

  // ------------------------------------------------------------------------
  // This method calculates how many submissions are APPROVED vs PENDING
  // across all "submissions" for all "tenders".
  // Adjust if your field name is something other than "status".
  // ------------------------------------------------------------------------
  Future<Map<String, int>> fetchApprovalStats() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    int approvedCount = 0;
    int pendingCount = 0;

    try {
      final tendersSnap = await _firestore.collection('tenders').get();
      for (var tenderDoc in tendersSnap.docs) {
        final submissionsSnap =
        await tenderDoc.reference.collection('submissions').get();

        for (var submissionDoc in submissionsSnap.docs) {
          final data = submissionDoc.data();
          final status = (data['status'] ?? '').toString().toUpperCase();

          if (status.contains('APPROVED') || status.contains('ACCEPTED')) {
            approvedCount++;
          } else if (status.contains('PENDING')) {
            pendingCount++;
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch approval stats: $e');
    }

    return {
      'APPROVED': approvedCount,
      'PENDING': pendingCount,
    };
  }
}
