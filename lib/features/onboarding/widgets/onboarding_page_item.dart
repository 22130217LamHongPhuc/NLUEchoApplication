import 'package:flutter/material.dart';
import '../models/onboarding_item.dart';

class OnboardingPageItem extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPageItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Center(
            child: Image.asset(
              item.image,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          item.description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}