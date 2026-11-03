import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/business_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/sale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  runApp(const VendeMasApp());
}

class VendeMasApp extends StatelessWidget {
  const VendeMasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
      ],
      child: MaterialApp.router(
        title: 'VendeMas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF006B5B),
          brightness: Brightness.light,
          fontFamily: 'Roboto',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF006B5B),
          brightness: Brightness.dark,
          fontFamily: 'Roboto',
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
