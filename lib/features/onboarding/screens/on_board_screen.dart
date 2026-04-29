import 'package:echo_nlu/core/providers/core_providers.dart';
import 'package:echo_nlu/features/onboarding/widgets/onboard_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/router/app_infor_router.dart';
import '../providers/onboarding_providers.dart';
import '../widgets/onboarding_action_bar.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_page_item.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  Future<void> _goToPage(int page) async {
    if(page == ref.read(onboardingProvider).currentPage) {
      ref.read(localStorageProvider).setFirstLaunchDone();
      context.goNamed(AppInforRouter.homePath);
      return;
    }
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleNext() async {
    final state = ref.read(onboardingProvider);
    final nextPage = state.currentPage + 1;
    await _goToPage(nextPage);
  }

  _navigateLogin(){
    context.goNamed(AppInforRouter.loginName);
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onboardingState.isLastPage ? null : () => _handleNext(),
                  child: Text(
                    'Bỏ qua',
                    style: TextStyle(
                      color: onboardingState.isLastPage
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingState.items.length,
                  onPageChanged: (index) {
                    ref.read(onboardingProvider.notifier).setCurrentPage(index);
                  },
                  itemBuilder: (context, index) {
                    return OnboardingPageItem(
                      item: onboardingState.items[index],
                    );
                  },
                ),
              ),
              OnboardingIndicator(
                currentIndex: onboardingState.currentPage,
                itemCount: onboardingState.items.length,
              ),


              const SizedBox(height: AppSpacing.xl),
              OnboardingActionBar(
                isLastPage: onboardingState.isLastPage,
                onNextPressed: onboardingState.isLastPage ? _navigateLogin :_handleNext,
              ),

            ],
          ),
        ),
      ),
    );
  }
}