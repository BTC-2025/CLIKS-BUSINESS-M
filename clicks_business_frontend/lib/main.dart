import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/navigation/pages/splash_screen.dart';
import 'features/navigation/shell_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryGreen,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: CliksBusinessApp(),
    ),
  );
}

class CliksBusinessApp extends StatefulWidget {
  const CliksBusinessApp({super.key});

  @override
  State<CliksBusinessApp> createState() => _CliksBusinessAppState();
}

class _CliksBusinessAppState extends State<CliksBusinessApp> {
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cliks Business',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isInitialized
          ? const ShellLayout()
          : SplashScreen(
              onInitializationComplete: () {
                setState(() {
                  _isInitialized = true;
                });
              },
            ),
    );
  }
}

