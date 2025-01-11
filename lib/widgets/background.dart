// lib/widgets/animated_web_background.dart
import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWebBackground extends StatefulWidget {
  const AnimatedWebBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedWebBackground> createState() => _AnimatedWebBackgroundState();
}

class _AnimatedWebBackgroundState extends State<AnimatedWebBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // List of icons in an office and AI context.
  final List<IconData> _icons = const [
    Icons.star,             // General highlight
    Icons.cloud,            // Connectivity/cloud
    Icons.computer,         // Office computer
    Icons.flash_on,         // Speed or power
    Icons.file_copy,        // Documents
    Icons.business_center,  // Office/business
    Icons.smart_toy,        // AI/robotics
    Icons.memory,           // Memory/chip (AI/data)
    Icons.data_usage,       // Data analytics
  ];

  // Define initial normalized positions (0.0 - 1.0) for each icon.
  final List<Offset> _startOffsets = const [
    Offset(0.1, 0.2),
    Offset(0.5, 0.1),
    Offset(0.3, 0.6),
    Offset(0.8, 0.4),
    Offset(0.2, 0.8),
    Offset(0.7, 0.75),
    Offset(0.15, 0.9),
    Offset(0.9, 0.2),
    Offset(0.4, 0.4),
  ];

  @override
  void initState() {
    super.initState();
    // A 20-second looping animation for gentle, continuous movement.
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Calculate a gentle offset variation based on a sine wave.
  Offset _calculateAnimatedOffset(Offset startOffset, double indexOffset) {
    final double rad = _controller.value * 2 * pi;
    // Adjust amplitude of movement (10% of the screen).
    const double amplitude = 0.1;
    final double dx = startOffset.dx + amplitude * sin(rad + indexOffset);
    final double dy = startOffset.dy + amplitude * cos(rad + indexOffset);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      // A slightly lighter and more complex gradient background.
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4FC3F7), // Lighter blue
            Color(0xFF81D4FA), // Even lighter blue
            Color(0xFFB3E5FC), // Very light blue
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      // Using AnimatedBuilder to rebuild as the animation updates.
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: List.generate(_icons.length, (index) {
              // Calculate new position for each icon.
              final animatedOffset =
              _calculateAnimatedOffset(_startOffsets[index], index.toDouble());

              // Convert normalized offset into actual screen coordinates.
              final double left = animatedOffset.dx * size.width;
              final double top = animatedOffset.dy * size.height;

              return Positioned(
                left: left,
                top: top,
                child: Icon(
                  _icons[index],
                  size: 48,
                  color: Colors.white.withOpacity(0.5), // 50% transparency
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
