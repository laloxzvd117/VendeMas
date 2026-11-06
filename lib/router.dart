import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/products/products_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/sell/done_screen.dart';
import 'features/sell/pay_screen.dart';
import 'features/sell/sell_screen.dart';
import 'shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/sell',
              builder: (_, _) => const SellScreen(),
              routes: [
                GoRoute(path: 'pay', builder: (_, _) => const PayScreen()),
                GoRoute(path: 'done', builder: (_, _) => const DoneScreen()),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/products', builder: (_, _) => const ProductsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/reports',
              builder: (_, _) => const ReportsScreen(),
              routes: [
                GoRoute(
                  path: ':key',
                  builder: (_, state) =>
                      ReportPage(reportKey: state.pathParameters['key'] ?? ''),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

const tabs = [
  (label: 'Inicio', icon: Icons.home_outlined, selected: Icons.home),
  (label: 'Vender', icon: Icons.shopping_cart_outlined, selected: Icons.shopping_cart),
  (label: 'Productos', icon: Icons.inventory_2_outlined, selected: Icons.inventory_2),
  (label: 'Reportes', icon: Icons.bar_chart_outlined, selected: Icons.bar_chart),
];
