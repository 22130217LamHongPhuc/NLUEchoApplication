import 'package:flutter/material.dart';

class OnboardButton extends StatelessWidget {
  final String titleButton;
  final VoidCallback onPressed;
  const OnboardButton({super.key, required this.titleButton, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child:  Text(titleButton)
      ),
    );
  }
}

