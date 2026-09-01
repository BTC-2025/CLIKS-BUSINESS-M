import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Referrals Hub',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner Card
                _buildHeader(isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
                const SizedBox(height: 24),

                // Main Info Container
                Container(
                  padding: EdgeInsets.all(isMobile ? 20 : 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReferralLinkSection(context, isMobile),
                      const SizedBox(height: 32),
                      _buildBenefitItem(
                        icon: LucideIcons.users,
                        iconColor: const Color(0xFF27AE60),
                        text: 'Friends join using your exclusive gateway link',
                      ),
                      const SizedBox(height: 20),
                      _buildBenefitItem(
                        icon: LucideIcons.link,
                        iconColor: const Color(0xFFF2994A),
                        text: 'Earn 500 points credited directly to wallet',
                      ),
                      const SizedBox(height: 20),
                      _buildBenefitItem(
                        icon: LucideIcons.checkCircle,
                        iconColor: const Color(0xFF2F80ED),
                        text: 'Redeem points for premium subscription cycles',
                      ),
                      const SizedBox(height: 36),
                      _buildSocialSection(isMobile),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F5B2E),
            Color(0xFF133C24),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2C94C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.gift, color: Color(0xFF0F5B2E), size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Refer & Earn Premium',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              children: [
                TextSpan(text: 'Introduce associates to CLIKS. For every active initialization, collect '),
                TextSpan(
                  text: '500 Points',
                  style: TextStyle(color: Color(0xFFF2C94C), fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' instantly!'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralLinkSection(BuildContext context, bool isMobile) {
    const String referralLink = 'https://cliksbusiness.com/join?ref=CLIK...';

    final copyButton = ElevatedButton.icon(
      onPressed: () {
        Clipboard.setData(const ClipboardData(text: referralLink));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
      },
      icon: const Icon(LucideIcons.copy, size: 16),
      label: const Text('Copy URL'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF132238),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR UNIQUE REFERRAL LINK',
          style: TextStyle(
            color: Color(0xFF828282),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: isMobile
              ? Column(
                  children: [
                    const Text(
                      referralLink,
                      style: TextStyle(
                        color: Color(0xFF27AE60),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: copyButton),
                  ],
                )
              : Row(
                  children: [
                    const Expanded(
                      child: Text(
                        referralLink,
                        style: TextStyle(
                          color: Color(0xFF27AE60),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    copyButton,
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4F4F4F),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection(bool isMobile) {
    final title = const Text(
      'Share Instantly:',
      style: TextStyle(
        color: Color(0xFF4F4F4F),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    final iconsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSocialIcon(LucideIcons.share2, const Color(0xFFF2F2F2), const Color(0xFF4F4F4F)),
        const SizedBox(width: 12),
        _buildSocialIcon(LucideIcons.send, const Color(0xFFE3F2FD), const Color(0xFF2196F3)),
        const SizedBox(width: 12),
        _buildSocialIcon(LucideIcons.messageCircle, const Color(0xFFE8EAF6), const Color(0xFF3F51B5)),
        const SizedBox(width: 12),
        _buildSocialIcon(LucideIcons.globe, const Color(0xFFE1F5FE), const Color(0xFF039BE5)),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 12),
          iconsRow,
        ],
      );
    }

    return Row(
      children: [
        title,
        const Spacer(),
        iconsRow,
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}
