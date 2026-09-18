import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReferEarnDialog extends StatelessWidget {
  const ReferEarnDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const ReferEarnDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.zero,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500,
          maxHeight: size.height * 0.65,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReferralLinkSection(context),
                    const SizedBox(height: 32),
                    _buildBenefitItem(
                      icon: LucideIcons.users,
                      iconColor: const Color(0xFF27AE60),
                      text: 'Friends join using your exclusive gateway link',
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      icon: LucideIcons.link,
                      iconColor: const Color(0xFFF2994A),
                      text: 'Earn 500 points credited directly to wallet',
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      icon: LucideIcons.checkCircle,
                      iconColor: const Color(0xFF2F80ED),
                      text: 'Redeem points for premium subscription cycles',
                    ),
                    const SizedBox(height: 32),
                    _buildSocialSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F5B2E),
            Color(0xFF133C24),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Drag Handle
          Positioned(
            top: 0,
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(LucideIcons.x, size: 16, color: Colors.white70),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
          Column(
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
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                  children: [
                    TextSpan(text: 'Introduce associates to CLIKS. For every active Initialization, collect '),
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
        ],
      ),
    );
  }

  Widget _buildReferralLinkSection(BuildContext context) {
    const String referralLink = 'https://cliksbusiness.com/join?ref=CLIK...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR UNIQUE REFERRAL LINK',
          style: TextStyle(
            color: Color(0xFF828282),
            fontSize: 12,
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
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  referralLink,
                  style: TextStyle(
                    color: Color(0xFF27AE60),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Row(
      children: [
        const Text(
          'Share Instantly:',
          style: TextStyle(
            color: Color(0xFF4F4F4F),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        _buildSocialIcon(LucideIcons.share2, const Color(0xFFF2F2F2), const Color(0xFF4F4F4F)),
        const SizedBox(width: 12),
        _buildSocialIcon(LucideIcons.send, const Color(0xFFE3F2FD), const Color(0xFF2196F3)),
        const SizedBox(width: 12),
        _buildSocialIcon(LucideIcons.messageCircle, const Color(0xFFE8EAF6), const Color(0xFF3F51B5)),
        const SizedBox(width: 12),
        _buildSocialIcon(LucideIcons.globe, const Color(0xFFE1F5FE), const Color(0xFF039BE5)),
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
