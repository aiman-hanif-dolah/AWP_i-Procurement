import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../providers/auth_provider.dart';

void showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Neumorphic(
          style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
              depth: 6,
              lightSource: LightSource.topLeft,
              intensity: 0.8,
              color: Colors.white
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7, // Set a relative width
            constraints: const BoxConstraints(maxWidth: 400), // Limit maximum width
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Emoji
                Text(
                  '👋',
                  style: const TextStyle(fontSize: 40),
                ).animate()
                    .shake(duration: const Duration(milliseconds: 600),
                ).scale(duration: const Duration(milliseconds: 800))
                    .then(delay: const Duration(milliseconds: 200)),
                const SizedBox(height: 12),
                // Title
                Text(
                  'Are you leaving?',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  'Logging out will end your session. Do you want to continue?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
                const SizedBox(height: 20),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    NeumorphicButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                          depth: 3,
                          color: Colors.grey.shade100
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey.shade900,
                        ),
                      ),
                    ).animate().fadeIn(duration: const Duration(milliseconds: 800))
                        .moveX(begin: -30, duration: const Duration(milliseconds: 800)),
                    const SizedBox(width: 10),
                    NeumorphicButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        await authProvider.logout(context);
                      },
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                          depth: 3,
                          color: Colors.red.shade600
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child:  const Text(
                        'Logout',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ).animate().fadeIn(duration: const Duration(milliseconds: 800))
                        .moveX(begin: 30, duration: const Duration(milliseconds: 800)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}