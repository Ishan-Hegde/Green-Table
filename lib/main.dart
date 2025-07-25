import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:green_table/pages/login_page.dart';
import 'package:green_table/screens/splash_screen.dart';
import 'package:green_table/screens/auth/registration_screen.dart';
import 'package:green_table/themes/theme_provider.dart';
import 'package:green_table/utils/role_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:path_provider/path_provider.dart'; // only used in mobile
import 'dart:io'; // only used in mobile

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // ✅ Web: No directory access needed
    await Hive.initFlutter();
  } else {
    // ✅ Mobile/Desktop: Use path_provider
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final hiveDirectory = Directory('${appDocumentDir.path}/hive');

    if (!await hiveDirectory.exists()) {
      await hiveDirectory.create(recursive: true);
    }

    await Hive.initFlutter(hiveDirectory.path);
  }

  await Hive.openBox('appSettings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/login': (context) => const LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          return MaterialPageRoute(builder: (_) => const RoleWrapper());
        }
        return null;
      },
      builder: (context, child) {
        return PopScope(
          canPop: navigatorKey.currentState?.canPop() ?? false,
          onPopInvokedWithResult: (bool didPop, result) {
            if (!didPop && (navigatorKey.currentState?.canPop() ?? false)) {
              navigatorKey.currentState?.pop();
            }
          },
          child: child!,
        );
      },
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeTransitionBuilder(),
            TargetPlatform.iOS: FadeTransitionBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeTransitionBuilder(),
            TargetPlatform.iOS: FadeTransitionBuilder(),
          },
        ),
      ),
    );
  }
}

class FadeTransitionBuilder extends PageTransitionsBuilder {
  const FadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
      child: child,
    );
  }
}
