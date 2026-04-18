import 'package:echo_nlu/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingActionBar extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onNextPressed;

  const OnboardingActionBar({
    super.key,
    required this.isLastPage,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onNextPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
        ),
        child: Text(isLastPage ? 'Bắt đầu' : 'Tiếp tục'),
      ),
    );
  }
}