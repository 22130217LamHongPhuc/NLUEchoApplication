import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_infor_router.dart';
import '../../../services/location_service.dart';
import '../providers/location_permission_provider.dart';

class LocationPermissionScreen extends ConsumerWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final permissionState = ref.watch(locationPermissionProvider);

    ref.listen(locationPermissionProvider, (previous, next) {
      next.whenOrNull(
        data: (status) {
          if (status == LocationStatus.granted) {
            context.go(AppInforRouter.homePath);
          }
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Có lỗi xảy ra: $error')),
          );
        },
      );
    });

    final isLoading = permissionState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF008542),
                    Color(0xFF3B74A1),
                    Color(0xFF6C63FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Cho phép truy cập vị trí',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _buildDescription(permissionState.value),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                        ref
                            .read(locationPermissionProvider.notifier)
                            .requestPermission();
                      },
                      child: isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text(
                        'Cho phép vị trí',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (permissionState.value == LocationStatus.deniedForever)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(locationPermissionProvider.notifier)
                            .openAppSettings();
                      },
                      child: const Text(
                        'Mở cài đặt ứng dụng',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                  if (permissionState.value == LocationStatus.serviceDisabled)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(locationPermissionProvider.notifier)
                            .openLocationSettings();
                      },
                      child: const Text(
                        'Mở cài đặt vị trí',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      ref
                          .read(locationPermissionProvider.notifier)
                          .checkPermission();
                    },
                    child: const Text(
                      'Kiểm tra lại',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

                  const Spacer(),
                  Text(
                    'NLU Echo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildDescription(LocationStatus? status) {
    switch (status) {
      case LocationStatus.serviceDisabled:
        return 'Thiết bị của bạn đang tắt GPS. Hãy bật GPS để sử dụng bản đồ và các tính năng xung quanh bạn.';
      case LocationStatus.deniedForever:
        return 'Bạn đã từ chối quyền vị trí vĩnh viễn. Vui lòng vào cài đặt ứng dụng để cấp lại quyền.';
      case LocationStatus.denied:
        return 'Ứng dụng cần quyền vị trí để hiển thị bản đồ và kết nối bạn với những người xung quanh.';
      case LocationStatus.granted:
        return 'Quyền vị trí đã được cấp.';
      default:
        return 'Ứng dụng cần quyền vị trí để hiển thị bản đồ và kết nối bạn với những người xung quanh.';
    }
  }
}