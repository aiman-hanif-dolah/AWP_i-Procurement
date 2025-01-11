import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AWP i-Procurement System'),
        actions: [
          if (currentUser != null)
            TextButton(
              onPressed: () async {
                await authProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Center(
        child: currentUser == null
            ? _buildGuestActions(context)
            : FutureBuilder<Map<String, dynamic>?>(
          future: authProvider.getUserData(currentUser.uid), // Assuming you fetch user data with `getUserData`
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Text('Error loading user data.');
            }

            final role = snapshot.data?['role'] ?? 'guest';
            return _buildRoleBasedActions(context, role);
          },
        ),
      ),
    );
  }

  // Guest actions for unauthenticated users
  Widget _buildGuestActions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text('Register as Vendor'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/tenders');
          },
          child: const Text('View Tenders'),
        ),
      ],
    );
  }

  // Role-based actions for authenticated users
  Widget _buildRoleBasedActions(BuildContext context, String role) {
    switch (role) {
      case 'admin':
        return ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/admin-dashboard');
          },
          child: const Text('Go to Admin Dashboard'),
        );
      case 'vendor':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome, Vendor!',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/tenders');
              },
              child: const Text('View Tenders'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/submit-tender'); // Navigate to tender submission
              },
              child: const Text('Submit Tender'),
            ),
          ],
        );
      default:
        return const Text('Invalid role or missing user data.');
    }
  }
}
