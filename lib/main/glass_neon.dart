import 'dart:ui';
import 'package:flutter/material.dart';

class NeonGlassAlert extends StatelessWidget {
  final String title;
  final String message;
  final Color neonColor; // e.g., neonPink or neonCyan
  final VoidCallback onAction;

  const NeonGlassAlert({
    super.key,
    required this.title,
    required this.message,
    required this.neonColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      // This creates the "Glass" blur effect
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor:
            Colors.white.withValues(alpha: 0.05), // Very transparent white
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: neonColor.withValues(alpha: 0.5), width: 1.5),
        ),
        content: Container(
          // Inner container for the Neon Glow
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: neonColor.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Icon
              Icon(Icons.warning_amber_rounded,
                  size: 50,
                  color: neonColor,
                  shadows: [
                    Shadow(color: neonColor, blurRadius: 20),
                  ]),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  color: neonColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  shadows: [Shadow(color: neonColor, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 25),
              // Neon Styled Button
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: neonColor),
                    color: neonColor.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    "ACKNOWLEDGE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: neonColor, blurRadius: 5)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
