import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  // Required for async operations before runApp (e.g., SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: SpecterApp(),
    ),
  );
}

class SpecterApp extends StatelessWidget {
  const SpecterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Specter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
