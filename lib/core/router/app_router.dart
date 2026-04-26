import 'package:echo_nlu/core/enums/echo_type.dart';
import 'package:echo_nlu/features/auth/screens/login_screen.dart';
import 'package:echo_nlu/features/auth/screens/register_screen.dart';
import 'package:echo_nlu/features/echo_detail/screens/echo_detail_screen.dart';
import 'package:echo_nlu/features/onboarding/screens/flash_screen.dart';
import 'package:echo_nlu/features/onboarding/screens/on_board_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../features/echo/screens/create_echo_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/permission/screens/location_permission_screen.dart';
import 'app_infor_router.dart';

final appRouter = GoRouter(
  initialLocation: AppInforRouter.echoDetailPath,
  routes: [
    GoRoute(
      path: AppInforRouter.splashPath,
      name: AppInforRouter.splashName,
      builder: (context, state) => FlashScreen(),
    ),

    GoRoute(
      path: AppInforRouter.registerPath,
      name: AppInforRouter.registerName,
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: AppInforRouter.loginPath,
      name: AppInforRouter.loginName,
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: AppInforRouter.onboardingPath,
      name: AppInforRouter.onboardingName,
      builder: (context, state) => OnboardingScreen(),
    ),
    GoRoute(
      path: AppInforRouter.homePath,
      name: AppInforRouter.homeName,
      builder: (context, state) => MapHomeScreen(),
    ),
    GoRoute(
      path: AppInforRouter.permissionsPath,
      name: AppInforRouter.permissionsName,
      builder: (context, state) => LocationPermissionScreen(),
    ),


    GoRoute(
      path: AppInforRouter.createEchoPath,
      name: AppInforRouter.createEchoName,
      builder: (context, state)  {
        final EchoType echoType = state.extra as EchoType;
        return CreateEchoScreen(
          echoType: echoType
        );
      }
    ),

    GoRoute(
        path: AppInforRouter.echoDetailPath,
        name: AppInforRouter.echoDetailName,
        builder: (context, state)  {
          // int echoId = int.parse(state.pathParameters['echoId']!);
          return EchoDetailScreen(
            echoId: 1,
          );
        }
    )








  ]
);