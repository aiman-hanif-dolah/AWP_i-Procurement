import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/appbar.dart';
import '../widgets/background.dart';

class AWPDashboardScreen extends StatefulWidget {
  const AWPDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AWPDashboardScreen> createState() => _AWPDashboardScreenState();
}

class _AWPDashboardScreenState extends State<AWPDashboardScreen> {
  // 1) Create the ScrollControllers
  final _verticalScrollController = ScrollController();
  final _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    // 2) Dispose of them when the widget is removed
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardItems = [
      {
        'icon': Icons.add_box,
        'title': 'Create Tender',
        'description': 'Post new tenders for vendors.',
        'onTap': () => Navigator.pushNamed(context, '/create-tender'),
      },
      {
        'icon': Icons.checklist,
        'title': 'Evaluate Tenders',
        'description': 'Review and rank submitted tenders.',
        'onTap': () => Navigator.pushNamed(context, '/AWP-evaluation'),
      },
      {
        'icon': Icons.analytics,
        'title': 'Reports',
        'description': 'View activity and submission reports.',
        'onTap': () => Navigator.pushNamed(context, '/AWP-reports'),
      },
    ];

    return Scaffold(
      appBar: const CustomAppBar(title: 'TM Malaysia - AWP Dashboard'),
      body: Stack(
        children: [
          // The reusable animated background widget.
          const AnimatedWebBackground(),

          // Content container with padding and background transparency.
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----- HEADER -----
                Text(
                  'Welcome to TM Malaysia Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor and manage all procurement activities efficiently.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),

                // ----- DASHBOARD TOP GRID (Create/Evaluate/Reports) -----
                Expanded(
                  child: MasonryGridView.count(
                    crossAxisCount: _getCrossAxisCount(context),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    itemCount: dashboardItems.length,
                    itemBuilder: (context, index) {
                      final item = dashboardItems[index];
                      return _buildAnimatedDashboardCard(
                        context,
                        icon: item['icon'] as IconData,
                        title: item['title'] as String,
                        description: item['description'] as String,
                        onTap: item['onTap'] as VoidCallback,
                        cardColor: _getCardColor(index),
                      );
                    },
                  ),
                ),

                // ----- ALL TENDERS TABLE -----
                Text(
                  'All Tenders',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor and manage all procurement activities efficiently.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Expanded(
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

                      final tenders = snapshot.data?.docs ?? [];

                      // If there are no tenders, show a friendly message.
                      if (tenders.isEmpty) {
                        return Center(
                          child: Text(
                            'No tenders found.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white),
                          ).animate().fadeIn(duration: 500.ms),
                        );
                      }

                      // ----- Modified Table Design with Scrollbars -----
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: Container(
                          key: ValueKey(tenders.length),
                          margin: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.white, Color(0xFFF2F2F2)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            // Wrap the vertical SingleChildScrollView with a Scrollbar
                            child: Scrollbar(
                              controller: _verticalScrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _verticalScrollController,
                                child: Scrollbar(
                                  controller: _horizontalScrollController,
                                  thumbVisibility: true,
                                  notificationPredicate: (notification) =>
                                  notification.metrics.axis == Axis.horizontal,
                                  child: SingleChildScrollView(
                                    controller: _horizontalScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dataTableTheme: DataTableThemeData(
                                          dataRowColor:
                                          MaterialStateProperty.all(Colors.white),
                                          dataTextStyle: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                          headingRowHeight: 60,
                                          columnSpacing: 16.0,
                                          horizontalMargin: 16.0,
                                        ),
                                      ),
                                      child: DataTable(
                                        headingRowHeight: 60,
                                        columns: [
                                          _buildGradientDataColumn(label: 'Tender ID'),
                                          _buildGradientDataColumn(label: 'Title'),
                                          _buildGradientDataColumn(label: 'Tender Type'),
                                          _buildGradientDataColumn(
                                              label: 'Person In Charge'),
                                          _buildGradientDataColumn(label: 'Description'),
                                          _buildGradientDataColumn(label: 'Tender Value'),
                                          _buildGradientDataColumn(label: 'Start Date'),
                                          _buildGradientDataColumn(label: 'End Date'),
                                          _buildGradientDataColumn(
                                              label: 'Contract Duration'),
                                          _buildGradientDataColumn(label: 'Remaining Time'),
                                          _buildGradientDataColumn(label: 'Status'),
                                        ],
                                        rows: tenders.map((tenderDoc) {
                                          final data =
                                          tenderDoc.data() as Map<String, dynamic>;

                                          // Safe extraction with fallback values:
                                          final tenderId = data['id'] ??
                                              data['procurementId'] ??
                                              'N/A';
                                          final title = data['title'] ?? 'N/A';
                                          final tenderType =
                                              data['tenderType'] ?? 'N/A';
                                          final personInCharge =
                                              data['personInCharge'] ?? 'N/A';
                                          final description =
                                              data['description'] ?? 'N/A';
                                          final tenderValue =
                                              data['tenderValue']?.toString() ?? 'N/A';

                                          DateTime? start;
                                          DateTime? end;
                                          if (data['startDate'] is Timestamp) {
                                            start = (data['startDate'] as Timestamp).toDate();
                                          } else if (data['startDate'] is String) {
                                            try {
                                              start = DateTime.parse(data['startDate']);
                                            } catch (_) {}
                                          }
                                          if (data['endDate'] is Timestamp) {
                                            end = (data['endDate'] as Timestamp).toDate();
                                          } else if (data['endDate'] is String) {
                                            try {
                                              end = DateTime.parse(data['endDate']);
                                            } catch (_) {}
                                          }

                                          final startDateString = start != null
                                              ? start.toLocal().toString().split(' ')[0]
                                              : 'N/A';
                                          final endDateString = end != null
                                              ? end.toLocal().toString().split(' ')[0]
                                              : 'N/A';

                                          String contractDuration = 'N/A';
                                          if (start != null && end != null) {
                                            final diffDays = end.difference(start).inDays;
                                            contractDuration = '$diffDays days';
                                          }

                                          String remainingTime = 'N/A';
                                          if (end != null) {
                                            final diffNow =
                                                end.difference(DateTime.now()).inDays;
                                            remainingTime = diffNow >= 0
                                                ? '$diffNow days remaining'
                                                : 'Tender Ended';
                                          }

                                          final status = data['status'] ?? 'N/A';

                                          return DataRow(
                                            cells: [
                                              DataCell(Text(tenderId)),
                                              DataCell(Text(title)),
                                              DataCell(Text(tenderType)),
                                              DataCell(Text(personInCharge)),
                                              DataCell(Text(description)),
                                              DataCell(Text(tenderValue)),
                                              DataCell(Text(startDateString)),
                                              DataCell(Text(endDateString)),
                                              DataCell(Text(contractDuration)),
                                              DataCell(Text(remainingTime)),
                                              DataCell(
                                                Text(
                                                  status,
                                                  style: TextStyle(
                                                    color: status.toLowerCase() == 'open'
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ).animate(
                            effects: [
                              FadeEffect(duration: 600.ms),
                              SlideEffect(
                                begin: const Offset(0, 0.1),
                                duration: 600.ms,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1400) return 4;
    if (width > 1024) return 3;
    return 2;
  }

  Widget _buildAnimatedDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onTap,
        required Color cardColor,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cardColor.withOpacity(0.8),
                cardColor.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.15),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataColumn _buildGradientDataColumn({required String label}) {
    return DataColumn(
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getCardColor(int index) {
    final colors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
    ];
    return colors[index % colors.length];
  }
}
