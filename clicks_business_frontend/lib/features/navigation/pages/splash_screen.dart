import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  String _loadingText = 'Securing connection...';

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Progress updates and simulation
    _progressController.addListener(() {
      if (!mounted) return;
      if (_progressController.value > 0.4 && _progressController.value < 0.8) {
        setState(() {
          _loadingText = 'Loading business configuration...';
        });
      } else if (_progressController.value >= 0.8) {
        setState(() {
          _loadingText = 'Launching workspace...';
        });
      }
    });

    _progressController.forward().then((_) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onInitializationComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F9FB),
              Color(0xFFFFFFFF),
              Color(0xFFF7F9FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              // App Logo inside the curvy light-green square
              Container(
                width: 160,
                height: 160,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // Light green covering curvy square fully
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Image.asset(
                  'assets/images/icon.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 32),
              // Brand Titles
              const Text(
                'CLIKS BUSINESS',
                style: TextStyle(
                  color: Color(0xFF0F2027),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ENTERPRISE FINANCIAL SUITE',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(flex: 2),
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: const Color(0xFFE0E0E0),
                        color: AppColors.primaryGreen,
                        minHeight: 4,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Loading Text
              Text(
                _loadingText,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
