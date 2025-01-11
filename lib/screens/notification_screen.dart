import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tender_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tenderProvider = Provider.of<TenderProvider>(context, listen: false);
    final vendorId = 'currentVendorId'; // Replace with the actual vendor ID logic

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: tenderProvider.fetchVendorNotifications(vendorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification['message']),
                subtitle: Text(notification['timestamp'].toDate().toString()),
              );
            },
          );
        },
      ),
    );
  }
}
