
import 'package:echo_nlu/core/router/app_infor_router.dart';
import 'package:echo_nlu/features/onboarding/widgets/onboard_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/core_providers.dart';
import '../../../services/location_service.dart';
import '../../../services/permission_service.dart';
class FlashScreen extends ConsumerStatefulWidget {
  const FlashScreen({super.key});

  @override
  ConsumerState<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends ConsumerState<FlashScreen> {
  bool _hasNavigated = false;

  void _go(String routePath) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    context.go(routePath);
  }

  @override
  void initState() {
    super.initState();

    ref.listenManual<AsyncValue<LocationStatus>>(
      locationPermissionProvider,
          (previous, next) {
        next.whenOrNull(
          data: (status) {
            final store = ref.read(localStorageProvider);
            if (status != LocationStatus.granted) {
              _go(AppInforRouter.permissionsPath);
            } else if (store.isFirstLaunch) {
              _go(AppInforRouter.homePath);
            } else if (store.token.isEmpty) {
              _go(AppInforRouter.loginPath);
            } else {
              _go(AppInforRouter.homePath);
            }
          },

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Stack(
      children: [
        // background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF008542),
                  Color(0xFF3B74A1),
                  Color(0xFF6C63FF),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        Image.asset('assets/images/flash.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity),


        // center content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', width: 250, height: 250),
              const SizedBox(height: 20),
               Text(
                'NLU Echo',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white
                )
              ),

            ],
          ),
        ),

        // bottom text
        Positioned(
          left: 0,
          right: 0,
          bottom: 70,
          child: Column(
            children: [
               Text(
                'Lưu giữ ký ức tại nơi bạn đứng',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(index == 1 ? 0.9 : 0.45),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),



              // OnboardButton(titleButton: 'Khám phá', onPressed: () => context.goNamed(AppInforRouter.onboardingName))


            ],
          ),
        ),
      ],
    );
  }

}