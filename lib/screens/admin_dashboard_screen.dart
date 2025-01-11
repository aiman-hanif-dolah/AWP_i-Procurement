import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/vendor-approvals');
            },
            child: const Text('Manage Vendors'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create-tender');
            },
            child: const Text('Create Tender'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/evaluate-tenders');
            },
            child: const Text('Evaluate Tenders'),
          ),
        ],
      ),
    );
  }
}
