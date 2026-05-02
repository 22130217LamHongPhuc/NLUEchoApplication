import 'package:echo_nlu/core/constants/app_spacing.dart';
import 'package:echo_nlu/features/history/components/list_history_echo.dart';
import 'package:echo_nlu/features/history/components/statitic_echo_history.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_size.dart';

class EchoHistoryScreen extends StatefulWidget {
  const EchoHistoryScreen({super.key});

  @override
  State<EchoHistoryScreen> createState() => _EchoHistoryScreenState();
}

class _EchoHistoryScreenState extends State<EchoHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        actions: [
          Center(
            child: Icon(Icons.location_on_outlined, color: AppColors.primary),
          ),
        ],
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hành trình của bạn',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: AppTextSize.lg,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.accent,
        elevation: 0,
      ),
      body: Container(
        color: AppColors.accent,
        child: Padding(
          padding:  EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StatisticEchoHistory(),
              SizedBox(height: AppTextSize.lg,),
              Expanded(
                child: ListHistoryEcho(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
