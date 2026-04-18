import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class CheckAccount extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  const CheckAccount({super.key, required this.title, required this.subtitle,
     required this.onPressed});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title,style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textMuted,
        ),),
        GestureDetector(
          onTap: onPressed,
          child: Text(subtitle,style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold
          ),),
        )
      ],
    );
  }
}
