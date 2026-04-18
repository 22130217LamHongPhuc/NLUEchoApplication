import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_size.dart';
import '../providers/create_echo_provider.dart';

class ItemAnonymous extends ConsumerWidget {


  const ItemAnonymous({super.key,


  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isAnonymous = ref.watch((createEchoProvider.select(
      (state) => state.isAnonymous,
    )));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.accent,
          child: Icon(
            Icons.visibility_off,
            color: AppColors.primary,
            size: AppTextSize.xl,
          ),
        ),


        title: Text('Ẩn danh',style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),),
        subtitle: Text('Echo này sẽ được tạo dưới dạng ẩn danh.',style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),),
        trailing: Switch(
          value: isAnonymous,
          onChanged: (value) {
            ref.read(createEchoProvider.notifier).updateIsAnonymous(value);
          },
          activeColor: Colors.white,
          activeTrackColor: AppColors.primaryLight,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.white,


          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight;
            }
            return Colors.grey;
          }),
        ),
      ),
    );
  }


}
