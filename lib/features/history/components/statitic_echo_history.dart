import 'package:echo_nlu/core/constants/app_colors.dart';
import 'package:echo_nlu/core/constants/app_spacing.dart';
import 'package:echo_nlu/core/constants/app_text_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticEchoHistory extends ConsumerWidget {
  const StatisticEchoHistory({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('Đã khám phá ', style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontSize: AppTextSize.lg
                      )),
                      SizedBox(height: AppSpacing.xl),
                      Text('40 Echoes', style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                          fontSize: AppTextSize.xxl
                      )),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(
                      AppSpacing.lg
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/star.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg,),
          Row(
            children: [
              Expanded(child: _statisticItem(theme,Icons.favorite,'Echo yêu thích', '80')),
              SizedBox(width: AppSpacing.lg,),
              Expanded(child: _statisticItem(theme,Icons.stars,'Echo đã tạo', '120')),

            ],
          )
        ],
      ),
    );
  }

  Widget _statisticItem(ThemeData theme,IconData icon, String description, String value) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.lg
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.lightGreen,
            size: AppTextSize.xxxl,
          ),
          SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
              fontSize: AppTextSize.xxl
          )),

          SizedBox(height: 4,),
          Text(description, style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontSize: AppTextSize.lg
          )),
        ],
      ),
    );
  }

}