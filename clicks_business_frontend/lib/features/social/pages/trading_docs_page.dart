import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class TradingDocsPage extends StatelessWidget {
  const TradingDocsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingVal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            _buildHeaderBanner(context, isMobile).animate().fadeIn(duration: 450.ms).slideY(begin: -0.05, end: 0),
            const SizedBox(height: 36),

            // Courses Wrap Layout (Zero Overflow)
            _buildCoursesGrid(isMobile).animate().fadeIn(duration: 500.ms, delay: 150.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1C6A), Color(0xFF19133D)], // Dark violet/indigo gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.graduationCap, color: AppColors.yellow, size: 12),
                SizedBox(width: 6),
                Text(
                  'INTEGRATED WEALTH CAMPUS',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Social Trading & Finance Academies',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start your financial learning journey today. Select a course below to master stock trading, automated investments, mutual funds, or safe gold bonds with simple, step-by-step lessons.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesGrid(bool isMobile) {
    final courses = [
      {
        'title': 'Enterprise Trading Academy',
        'badge': 'STOCK TRADING',
        'desc': 'A complete 25-lesson course to master reading stock charts, analyzing company financials, and learning easy trading strategies.',
        'icon': LucideIcons.trendingUp,
        'color': AppColors.primaryGreen,
      },
      {
        'title': 'SIP Wealth Builder',
        'badge': 'SIP & COMPOUNDING',
        'desc': 'Discover how to set up systematic plans, automatically increase your savings monthly, and use compounding to reach your goals.',
        'icon': LucideIcons.activity,
        'color': AppColors.blue,
      },
      {
        'title': 'Mutual Funds Masterclass',
        'badge': 'MUTUAL FUNDS',
        'desc': 'An easy-to-follow masterclass on picking top-performing funds, understanding index funds, and reducing investment fees.',
        'icon': LucideIcons.pieChart,
        'color': AppColors.purpleAccent,
      },
      {
        'title': 'Alternative Assets & Debt',
        'badge': 'GOLD & SAFE BONDS',
        'desc': 'A professional guide to earning stable returns from secure government schemes, gold bonds, and rental real estate.',
        'icon': LucideIcons.diamond,
        'color': Colors.orange,
      },
      {
        'title': 'Crypto & Web3 Essentials',
        'badge': 'CRYPTO & WEB3',
        'desc': 'An actionable 25-lesson course explaining Smart Contracts, Decentralized Exchanges, and Indian crypto tax rules.',
        'icon': LucideIcons.zap,
        'color': Colors.indigo,
      },
      {
        'title': 'Bitcoin Masterclass',
        'badge': 'BITCOIN HARD MONEY',
        'desc': 'A professional 25-lesson curriculum detailing Bitcoin Mining, the 21M Hard Cap, and cold storage wallets.',
        'icon': LucideIcons.coins,
        'color': Colors.deepOrange,
      },
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: courses.map((c) {
        return SizedBox(
          width: isMobile ? double.infinity : 340,
          child: _buildCourseCard(c),
        );
      }).toList(),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final Color iconColor = course['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(course['icon'] as IconData, color: iconColor, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.hoverBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  course['badge'] as String,
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            course['title'] as String,
            style: const TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            course['desc'] as String,
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 12, height: 1.4),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Launch Learning Track',
                  style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 6),
                Icon(LucideIcons.arrowRight, color: iconColor, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
