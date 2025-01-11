// lib/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'logout.dart'; // Import your logout confirmation dialog

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLogout;
  final bool showBackButton;
  final String? backRoute;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showLogout = true,
    this.showBackButton = false,
    this.backRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a dark blue gradient for the AppBar foreground.
    // These values override any gradient defined in AppTheme.
    const darkBlueGradient = LinearGradient(
      colors: [
        Color(0xFF0D47A1), // Dark blue
        Color(0xFF1976D2), // Slightly lighter dark blue
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AppBar(
      // Optional back button
        leading: showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            if (backRoute != null) {
              // Navigate to the specified route and remove all previous routes.
              Navigator.pushNamedAndRemoveUntil(
                context,
                backRoute!,
                    (route) => false,
              );
            } else {
              // Pop the current screen from the stack.
              Navigator.pop(context);
            }
          },
        )
          : null,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated emoji
          Text(
            '📂',
            style: const TextStyle(fontSize: 24),
          )
              .animate()
              .shake(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(milliseconds: 1000),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 4,
      // Use the dark blue gradient defined above.
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: darkBlueGradient,
        ),
      ),
      actions: [
        // Logout button with tooltip
        if (showLogout)
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            tooltip: 'Logout',
            onPressed: () {
              showLogoutConfirmationDialog(context);
            },
          ),
        // Avatar placeholder (for future profile image or initials)
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
