import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iprocurement/providers/submission_provider.dart';
import 'package:iprocurement/screens/admin_dashboard_screen.dart';
import 'package:iprocurement/screens/admin_evaluation_screen.dart';
import 'package:iprocurement/screens/admin_vendor_screen.dart';
import 'package:iprocurement/screens/tender_creation_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/tender_provider.dart';
import 'providers/vendor_provider.dart'; // Import VendorProvider

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TenderProvider()),
        ChangeNotifierProvider(create: (_) => SubmissionProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()), // Add VendorProvider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AWP i-Procurement',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/vendor-approvals': (context) => const AdminVendorScreen(),
          '/create-tender': (context) => const TenderCreationScreen(),
          '/evaluate-tenders': (context) => const AdminEvaluationScreen(),
        },
      ),
    );
  }
}
