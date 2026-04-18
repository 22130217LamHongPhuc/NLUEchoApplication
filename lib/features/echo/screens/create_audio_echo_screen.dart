import 'package:echo_nlu/core/constants/app_text_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';

class CreateAudioEchoScreen extends ConsumerWidget {
  const CreateAudioEchoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      return Scaffold(
        backgroundColor: AppColors.accent,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          ),
          actions: [
            Icon(Icons.location_on_outlined, color: AppColors.primary),
          ],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Tạo Echo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppTextSize.lg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Hồ đá Nông Lâm',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppTextSize.md,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.transparent,
          elevation: 0,

        ),
        body: Center(
          child: Text('Giao diện tạo tiếng vọng văn bản/hình ảnh sẽ được xây dựng ở đây.'),
        ),
      );
  }


}
