import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/scan/scan_screen.dart';
import '../../features/spirit_box/spirit_box_screen.dart';
import '../../features/commune/commune_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/navigation_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return NavigationShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/scan',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ScanScreen(),
          ),
        ),
        GoRoute(
          path: '/spirit-box',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SpiritBoxScreen(),
          ),
        ),
        GoRoute(
          path: '/commune',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CommuneScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
