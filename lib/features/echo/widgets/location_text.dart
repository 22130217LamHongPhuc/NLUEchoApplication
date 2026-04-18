import 'package:flutter/cupertino.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_size.dart';



class LocationText extends StatelessWidget {
  final String? locationName;
  final bool isLoading;

  const LocationText({
    super.key,
    required this.locationName,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CupertinoActivityIndicator(color: AppColors.primary)
        : Text(
            locationName ?? 'Chọn vị trí',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppTextSize.md,
            ),
          );
  }
}
