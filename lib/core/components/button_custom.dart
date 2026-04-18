import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ButtonCustom extends StatelessWidget {
  final String titleButton;
  final VoidCallback onNextPressed;
  const ButtonCustom({super.key, required this.titleButton, required this.onNextPressed});

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
        child: Text(titleButton),
      ),
    );
  }
}
