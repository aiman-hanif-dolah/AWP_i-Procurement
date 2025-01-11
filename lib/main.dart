import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iprocurement/providers/tender_provider.dart';
import 'package:iprocurement/screens/apply_tender_screen.dart';
import 'package:iprocurement/screens/awp_dashboard_screen.dart';
import 'package:iprocurement/screens/awp_evaluation_screen.dart';
import 'package:iprocurement/screens/awp_reports_screen.dart';
import 'package:iprocurement/screens/filter_table_screen.dart';
import 'package:iprocurement/screens/tender_submission_screen.dart';
import 'package:iprocurement/screens/vendor_dashboard_screen.dart';
import 'package:iprocurement/screens/view_application_screen.dart';
import 'package:iprocurement/services/theme.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/submission_provider.dart';

import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/tender_creation_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TenderProvider()),
        ChangeNotifierProvider(create: (_) => SubmissionProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'AWP i-Procurement',
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/AWP-dashboard': (context) => const AWPDashboardScreen(),
          '/AWP-reports': (context) => const AWPReportsScreen(),
          '/AWP-evaluation': (context) => const AWPEvaluationScreen(),
          '/evaluate-tenders': (context) => const AWPEvaluationScreen(),
          '/vendor-dashboard': (context) => const VendorDashboardScreen(),
          '/create-tender': (context) => const TenderCreationScreen(),
          '/submit-tender': (context) => const TenderSubmissionScreen(),
          '/apply-tender': (context) => const ApplyTenderScreen(),
          '/view-vendor-applications': (context) => const ViewApplicationScreen(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      ),
    );
  }
}
