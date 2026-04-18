import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/on_board_controller.dart';

final onboardingProvider = NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);

