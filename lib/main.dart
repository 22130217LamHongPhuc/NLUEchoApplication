import 'package:echo_nlu/core/router/app_router.dart';
import 'package:echo_nlu/services/local_storeage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/core_providers.dart';


Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final localStorageService = await LocalStorageService.init();

  runApp(ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorageService),
      ],
      child: const MyApp()));

}
void main() async {
  await bootstrap();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Echo NLU',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
