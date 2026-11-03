import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/sell/sell_screen.dart';
import '../../presentation/screens/pay/pay_screen.dart';
import '../../presentation/screens/pay/confirmation_screen.dart';
import '../../presentation/screens/products/products_screen.dart';
import '../../presentation/screens/products/add_product_screen.dart';
import '../../presentation/screens/products/stock_screen.dart';
import '../../presentation/screens/reports/reports_menu_screen.dart';
import '../../presentation/screens/reports/rank/rank_screen.dart';
import '../../presentation/screens/reports/abc/abc_screen.dart';
import '../../presentation/screens/reports/matrix/matrix_screen.dart';
import '../../presentation/screens/reports/dead/dead_screen.dart';
import '../../presentation/screens/reports/hours/hours_screen.dart';
import '../../presentation/screens/reports/pairs/pairs_screen.dart';
import '../../presentation/screens/reports/trend/trend_screen.dart';
import '../../presentation/screens/reports/weekly/weekly_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/shell_screen.dart';
import '../../presentation/desktop/desktop_shell.dart';
import '../../presentation/desktop/views/desk_weekly_view.dart';
import '../../presentation/desktop/views/desk_rank_view.dart';
import '../../presentation/desktop/views/desk_abc_view.dart';
import '../../presentation/desktop/views/desk_matrix_view.dart';
import '../../presentation/desktop/views/desk_dead_view.dart';
import '../../presentation/desktop/views/desk_hours_view.dart';
import '../../presentation/desktop/views/desk_pairs_view.dart';
import '../../presentation/desktop/views/desk_trend_view.dart';

bool get isDesktopPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS);

String get homeRoute => isDesktopPlatform ? '/desk/weekly' : '/home';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => DesktopShell(child: child),
      routes: [
        GoRoute(path: '/desk/weekly', builder: (context, state) => const DeskWeeklyView()),
        GoRoute(path: '/desk/rank', builder: (context, state) => const DeskRankView()),
        GoRoute(path: '/desk/abc', builder: (context, state) => const DeskAbcView()),
        GoRoute(path: '/desk/matrix', builder: (context, state) => const DeskMatrixView()),
        GoRoute(path: '/desk/dead', builder: (context, state) => const DeskDeadView()),
        GoRoute(path: '/desk/hours', builder: (context, state) => const DeskHoursView()),
        GoRoute(path: '/desk/pairs', builder: (context, state) => const DeskPairsView()),
        GoRoute(path: '/desk/trend', builder: (context, state) => const DeskTrendView()),
      ],
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/sell',
          builder: (context, state) => const SellScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsScreen(),
          routes: [
            GoRoute(
              path: 'add',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const AddProductScreen(),
            ),
            GoRoute(
              path: 'stock',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const StockScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsMenuScreen(),
          routes: [
            GoRoute(
              path: 'rank',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const RankScreen(),
            ),
            GoRoute(
              path: 'abc',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const AbcScreen(),
            ),
            GoRoute(
              path: 'matrix',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const MatrixScreen(),
            ),
            GoRoute(
              path: 'dead',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const DeadScreen(),
            ),
            GoRoute(
              path: 'hours',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const HoursScreen(),
            ),
            GoRoute(
              path: 'pairs',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const PairsScreen(),
            ),
            GoRoute(
              path: 'trend',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const TrendScreen(),
            ),
            GoRoute(
              path: 'weekly',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const WeeklyScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/pay',
      builder: (context, state) => const PayScreen(),
    ),
    GoRoute(
      path: '/confirmation',
      builder: (context, state) => const ConfirmationScreen(),
    ),
  ],
);
