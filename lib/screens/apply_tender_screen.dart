import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../providers/tender_provider.dart';
import '../widgets/appbar.dart';
import '../widgets/background.dart';

class ApplyTenderScreen extends StatelessWidget {
  const ApplyTenderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tenderProvider = Provider.of<TenderProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Explore Tenders',
        showBackButton: true,
        showLogout: true,
        backRoute: '/vendor-dashboard',
      ),
      body: Stack(
        children: [
          const AnimatedWebBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discover Opportunities',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Browse through the latest tenders available for application.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: StreamBuilder(
                      stream: tenderProvider.fetchTenders(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Error loading tenders'),
                          );
                        }
                        if (!snapshot.hasData ||
                            (snapshot.data as List).isEmpty) {
                          return const Center(
                            child: Text(
                              'No tenders available at the moment.',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        final allTenders = snapshot.data as List;
                        final now = DateTime.now();
                        final validTenders = allTenders.where((tender) {
                          final bool isOpen = tender.isOpen;
                          final DateTime? end = tender.endDate;
                          final bool notExpired =
                              (end != null) ? end.isAfter(now) : false;
                          return isOpen && notExpired;
                        }).toList();

                        if (validTenders.isEmpty) {
                          return const Center(
                            child: Text(
                              'No valid tenders available right now.',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return MasonryGridView.count(
                          crossAxisCount: _getCrossAxisCount(context),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          itemCount: validTenders.length,
                          itemBuilder: (context, index) {
                            final tender = validTenders[index];
                            return _buildTenderCard(context, tender)
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slide(begin: const Offset(0, 0.1));
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  Future<void> _selectTender(BuildContext context, String tenderId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTenderId', tenderId);
    Navigator.pushNamed(
      context,
      '/submit-tender',
      arguments: tenderId,
    );
  }

  Widget _buildTenderCard(BuildContext context, dynamic tender) {
    final bool isOpen = tender.isOpen;
    final String statusString = isOpen ? 'OPEN' : 'CLOSED';
    final String title = tender.title ?? 'No Title';
    final String description =
        tender.description ?? 'No Description'; // Get description
    DateTime? start = tender.startDate;
    DateTime? end = tender.endDate;

    String contractDuration = 'N/A';
    if (start != null && end != null) {
      final diffDays = end.difference(start).inDays;
      contractDuration = '$diffDays days';
    }

    String remainingTime = 'N/A';
    if (end != null) {
      final diffNow = end.difference(DateTime.now());
      if (diffNow.isNegative) {
        remainingTime = 'Tender Ended';
      } else if (diffNow.inDays > 0) {
        remainingTime = '${diffNow.inDays} days remaining';
      } else if (diffNow.inHours > 0) {
        remainingTime = '${diffNow.inHours} hours remaining';
      } else if (diffNow.inMinutes > 0) {
        remainingTime = '${diffNow.inMinutes} minutes remaining';
      } else {
        remainingTime = 'Less than a minute left';
      }
    }

    final Color statusColor =
        isOpen ? Colors.green.shade600 : Colors.red.shade600;

    return GestureDetector(
      onTap: () => _selectTender(context, tender.submissionId),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor.withOpacity(0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(
                    label: Text(
                      statusString,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: statusColor,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description, // Display description
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(PhosphorIcons.briefcase(PhosphorIconsStyle.regular),
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Duration: $contractDuration',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(PhosphorIcons.clock(PhosphorIconsStyle.regular),
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Remaining: $remainingTime',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: () => _selectTender(context, tender.submissionId),
                  icon: const Icon(
                      Icons.run_circle_outlined, // Use standard Flutter Icon
                      size: 16,
                      color: Colors.white),
                  label: const Text('Apply Now',
                      style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ).animate().scale(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
