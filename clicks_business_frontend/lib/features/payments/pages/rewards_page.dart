import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

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
            // Header Section
            _buildHeader(isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
            const SizedBox(height: 32),

            // Active Plan Banner Card
            _buildActivePlanBanner(context, isMobile).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            const SizedBox(height: 40),

            // Section Header
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Exclusive Offers & Boosters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.clock, size: 14, color: AppColors.secondaryText),
                    const SizedBox(width: 6),
                    const Text(
                      'Updated Hourly',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 24),

            // Booster Cards Grid/List
            _buildOffersGrid(context, isMobile).animate().fadeIn(duration: 500.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.hoverBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(LucideIcons.gift, color: AppColors.primaryGreen, size: 24),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rewards & Offers',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkText),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                'Unlock special platform deals, discounts, and premium tier unlocks.',
                style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivePlanBanner(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4421), // Dark forest green
        borderRadius: BorderRadius.circular(24),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerLeftSection(),
                const SizedBox(height: 24),
                _buildPointsCard(context, isMobile),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 6, child: _buildBannerLeftSection()),
                const SizedBox(width: 40),
                Expanded(flex: 4, child: _buildPointsCard(context, isMobile)),
              ],
            ),
    );
  }

  Widget _buildBannerLeftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.checkCircle, color: Colors.white, size: 12),
              SizedBox(width: 6),
              Text(
                'ACTIVE REWARDS PLAN',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Grow Your Business, Collect Premium Perks',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Complete milestones, scale your active ledger, and transact consistently to stack loyalty points and unlock deep discounts across your workspace subscriptions.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildPointsCard(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF083318), // Deeper green
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.yellow, shape: BoxShape.circle),
                child: const Icon(LucideIcons.coins, color: Color(0xFF083318), size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'TOTAL WALLET POINTS',
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1,450',
            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const Text(
            '≈ ₹14.50 Value',
            style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.yellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'Gold Elite 👑',
              style: TextStyle(color: AppColors.yellow, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                AppSnackbar.show(
                  context,
                  "Success: converted reward points to wallet balance.",
                  type: SnackType.success,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: const Color(0xFF083318),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Convert to Wallet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersGrid(BuildContext context, bool isMobile) {
    final offers = [
      {
        'title': 'Starter Wallet Load Reward',
        'badge': '2% OFF PRO',
        'desc': 'Load ₹5,000 or more into your Cliks Wallet and claim a 2% flat discount on your next monthly or annual Cliks Pro subscription.',
        'color': AppColors.success,
      },
      {
        'title': 'Silver Wallet Load Reward',
        'badge': '3.5% OFF PRO',
        'desc': 'Load ₹10,000 or more into your Cliks Wallet and claim a 3.5% flat discount on your next monthly or annual Cliks Pro subscription.',
        'color': AppColors.blue,
      },
      {
        'title': 'Gold Wallet Load Reward',
        'badge': '5% OFF PRO',
        'desc': 'Load ₹25,000 or more into your Cliks Wallet and claim a 5% flat discount on your next monthly or annual Cliks Pro subscription.',
        'color': AppColors.yellow,
      },
      {
        'title': 'Platinum Wallet Load Reward',
        'badge': '8% OFF PRO',
        'desc': 'Load ₹50,000 or more into your Cliks Wallet and claim a 8% flat discount on your next monthly or annual Cliks Pro subscription.',
        'color': AppColors.purpleAccent,
      },
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: offers.map((o) {
        return SizedBox(
          width: isMobile ? double.infinity : 340,
          child: _buildOfferCard(context, o),
        );
      }).toList(),
    );
  }

  Widget _buildOfferCard(BuildContext context, Map<String, dynamic> offer) {
    final Color badgeColor = offer['color'] as Color;
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
                  color: badgeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.wallet, color: badgeColor, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  offer['badge'] as String,
                  style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            offer['title'] as String,
            style: const TextStyle(color: AppColors.darkText, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            offer['desc'] as String,
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 12, height: 1.4),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              AppSnackbar.show(
                context,
                "Loading wallet integration gateway... Please wait.",
                type: SnackType.info,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Load Wallet Now',
                  style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 6),
                Icon(LucideIcons.arrowRight, color: badgeColor, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
