import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/config/supabase_config.dart';

void main() async {
  // Required for async operations before runApp (e.g., SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Silent auth so we can protect edge functions with a JWT without adding UX friction.
  final client = Supabase.instance.client;
  if (client.auth.currentSession == null) {
    try {
      await client.auth.signInAnonymously();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Supabase anonymous sign-in failed: $e');
      }
    }
  }

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
