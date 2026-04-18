import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_size.dart';
import '../providers/create_echo_provider.dart';

class ItemCapsule extends ConsumerWidget {

  final FocusNode contentFocus ;
  final FocusNode titleFocus;

  const ItemCapsule({super.key,
    required this.contentFocus,
    required this.titleFocus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCapsule = ref.watch(
      createEchoProvider.select((s) => s.isCapsule),
    );

    final scheduledTime = ref.watch(
      createEchoProvider.select((s) => s.scheduledTime),
    );
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.accent,
              child: Icon(
                Icons.watch_later,
                color: AppColors.primary,
                size: AppTextSize.xl,
              ),
            ),

            title: Text('Kén ký ức',style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),),
            subtitle: Text('Echo sẽ được nở trong tương lai',style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),),
            trailing: Switch(
              value: isCapsule,
              onChanged: (value){
                  ref.read(createEchoProvider.notifier).updateIsCapsule(value);
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

          isCapsule ? ListTile(
            tileColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              scheduledTime != null
                  ? 'Đã lên lịch: ${scheduledTime.day}/${scheduledTime.month}/${scheduledTime.year}'
                  : 'Chọn ngày nở',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(Icons.calendar_month_sharp),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              contentFocus.unfocus(
                disposition: UnfocusDisposition.scope,
              );
              titleFocus.unfocus(
                disposition: UnfocusDisposition.scope,
              );


              if (picked != null) {
                ref.read(createEchoProvider.notifier).updateScheduledTime(
                    picked);
              }
            }
          ): Container()


        ],
      ),
    );
  }


}
