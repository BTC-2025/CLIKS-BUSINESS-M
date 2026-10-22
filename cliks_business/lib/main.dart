import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/notifiers/auth_notifier.dart';
import 'features/auth/pages/login_screen.dart';
import 'features/navigation/pages/splash_screen.dart';
import 'features/navigation/shell_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.headerBackground,
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

class CliksBusinessApp extends ConsumerStatefulWidget {
  const CliksBusinessApp({super.key});

  @override
  ConsumerState<CliksBusinessApp> createState() => _CliksBusinessAppState();
}

class _CliksBusinessAppState extends ConsumerState<CliksBusinessApp> {
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Cliks Business',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: !_isInitialized
          ? SplashScreen(
              onInitializationComplete: () {
                setState(() {
                  _isInitialized = true;
                });
              },
            )
          : (authState.isLoggedIn ? const ShellLayout() : const LoginScreen()),
    );
  }
}

