import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:manganku_app/routes/app_router.dart';
import 'package:manganku_app/core/theme/app_theme.dart';

class ManganKuApp extends StatelessWidget {
  const ManganKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp.router(
            title: 'ManganKu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
}
