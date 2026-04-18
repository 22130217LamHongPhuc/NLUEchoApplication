import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const Header({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

     return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors.primary,
            )
        ),
        SizedBox(height: AppSpacing.xxl),
        Text(title,style: theme.textTheme.headlineLarge?.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold
        ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(subtitle,style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic
        ),
        )
      ],
    );
  }
}
