import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/map_home_state.dart';

class LocationStatusBanner extends StatelessWidget {
  final String text;
  final NluAccessState accessState;


  const LocationStatusBanner({super.key,
    required this.text,
    required this.accessState,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (accessState) {
      NluAccessState.insideNLU => const Color(0xFF66F5AF),
      NluAccessState.nearNLU => const Color(0xFFFFB84D),
      NluAccessState.outsideNLU => const Color(0xFFFF6A8B),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.45)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.8,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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