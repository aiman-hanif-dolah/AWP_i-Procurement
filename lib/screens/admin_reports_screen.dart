import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/vendor_provider.dart';
import '../providers/tender_provider.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final tenderProvider = Provider.of<TenderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Reports'),
      ),
      body: FutureBuilder(
        future: Future.wait([
          vendorProvider.fetchVendorsReport(), // Replace with appropriate method
          tenderProvider.fetchTendersReport(), // Replace with appropriate method
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading reports: ${snapshot.error}'));
          }

          final reports = snapshot.data as List;
          final vendorReport = reports[0] as List<Map<String, dynamic>>;
          final tenderReport = reports[1] as List<Map<String, dynamic>>;

          return ListView(
            children: [
              const Text('Vendor Report:', style: TextStyle(fontSize: 18)),
              ...vendorReport.map((data) => ListTile(
                title: Text(data['companyName'] ?? 'Unknown'),
                subtitle: Text('Status: ${data['status'] ?? 'N/A'}'),
              )),
              const SizedBox(height: 20),
              const Text('Tender Report:', style: TextStyle(fontSize: 18)),
              ...tenderReport.map((data) => ListTile(
                title: Text(data['title'] ?? 'Unknown'),
                subtitle: Text(
                    'Deadline: ${data['submissionDeadline']?.toDate().toString() ?? 'N/A'}'),
              )),
            ],
          );
        },
      ),
    );
  }
}
