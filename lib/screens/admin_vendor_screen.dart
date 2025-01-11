import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vendor_provider.dart';

class AdminVendorScreen extends StatelessWidget {
  const AdminVendorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vendorProvider = Provider.of<VendorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Approvals'),
      ),
      body: FutureBuilder(
        future: vendorProvider.fetchVendors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final vendors = vendorProvider.vendors;

          if (vendors.isEmpty) {
            return const Center(
              child: Text('No vendor registrations found.'),
            );
          }

          return ListView.builder(
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              final vendor = vendors[index];
              return ListTile(
                title: Text(vendor['companyName']),
                subtitle: Text('Status: ${vendor['status']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        vendorProvider.updateVendorStatus(
                          vendor['id'],
                          'Approved',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        vendorProvider.updateVendorStatus(
                          vendor['id'],
                          'Rejected',
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
