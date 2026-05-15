import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/app_shell.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<Locale>    localeNotifier    = ValueNotifier(const Locale('fr'));
final ValueNotifier<int>       tabNotifier       = ValueNotifier(0);

void main() {
  runApp(const CostalinaApp());
}

class CostalinaApp extends StatelessWidget {
  const CostalinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (ctx, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: isDark ? CoastPalette.dark.navBg : CoastPalette.light.navBg,
        ));
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (_, locale, _) => MaterialApp(
            title: 'Costalina',
            debugShowCheckedModeBanner: false,
            theme:      buildCostalinaTheme(Brightness.light),
            darkTheme:  buildCostalinaTheme(Brightness.dark),
            themeMode:  themeMode,
            locale: locale,
            supportedLocales: const [
              Locale('fr'), Locale('en'), Locale('ar'),
              Locale('es'), Locale('de'), Locale('it'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case '/login':
                  final m = settings.arguments is String
                      ? settings.arguments as String : 'login';
                  return MaterialPageRoute(builder: (_) => LoginScreen(initialMode: m));
                case '/app':
                  return MaterialPageRoute(builder: (_) => const AppShell());
                default:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
              }
            },
          ),
        );
      },
    );
  }
}