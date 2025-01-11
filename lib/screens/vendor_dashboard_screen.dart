import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tender_provider.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tenderProvider = Provider.of<TenderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
      ),
      body: StreamBuilder(
        stream: tenderProvider.fetchTenders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text('No tenders available.'));
          }

          final tenders = snapshot.data as List;
          return ListView.builder(
            itemCount: tenders.length,
            itemBuilder: (context, index) {
              final tender = tenders[index];
              return ListTile(
                title: Text(tender.title),
                subtitle: Text(
                  'Deadline: ${tender.submissionDeadline.toLocal()}',
                ),
                trailing: tender.isOpen
                    ? const Text('Open', style: TextStyle(color: Colors.green))
                    : const Text('Closed', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/submit-tender',
                    arguments: tender.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
