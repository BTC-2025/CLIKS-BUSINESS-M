import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  static const String _referralLink = 'https://cliksbusiness.com/join?ref=CLIK-BIZ99';
  static const String _referralCode = 'CLIK-BIZ99';

  bool _isLinkCopied = false;
  bool _isCodeCopied = false;

  void _copyToClipboard(String text, {required bool isCode}) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();

    setState(() {
      if (isCode) {
        _isCodeCopied = true;
      } else {
        _isLinkCopied = true;
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.check, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              isCode ? 'Referral code copied to clipboard!' : 'Referral link copied to clipboard!',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          if (isCode) {
            _isCodeCopied = false;
          } else {
            _isLinkCopied = false;
          }
        });
      }
    });
  }

  void _shareCustomMessage() {
    const String message =
        'Hey! Join me on Cliks Business to manage billing, invoicing & operations smoothly. '
        'Sign up using my invite link to get starter bonus credits: $_referralLink (Invite Code: $_referralCode)';
    Clipboard.setData(const ClipboardData(text: message));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.check, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Invitation message copied! Ready to paste & send.',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF064E3B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(LucideIcons.sparkles, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Referral stats refreshed',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF064E3B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: const Color(0xFF00A86B),
        backgroundColor: Colors.white,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 28,
            isMobile ? 16 : 24,
            isMobile ? 16 : 28,
            isMobile ? 130 : 48,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Premium Emerald Hero Banner Card
                  _buildHeroBanner(isMobile)
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: -0.04, end: 0),
                  const SizedBox(height: 18),

                  // 2. Metrics / Performance Summary
                  _buildMetricsRow(isMobile)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.04, end: 0),
                  const SizedBox(height: 20),

                  // 3. Main Referral Action Card (Link + Code + Copy)
                  _buildReferralActionCard(isMobile)
                      .animate()
                      .fadeIn(duration: 450.ms, delay: 150.ms),
                  const SizedBox(height: 20),

                  // 4. How It Works (3 Modern Steps)
                  _buildHowItWorksSection(isMobile)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 20),

                  // 5. Direct Sharing Channels
                  _buildDirectShareCard(isMobile)
                      .animate()
                      .fadeIn(duration: 550.ms, delay: 250.ms),
                  const SizedBox(height: 16),

                  // 6. Assurance Footer Banner
                  _buildAssuranceBanner()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Hero Banner
  // ---------------------------------------------------------------------------
  Widget _buildHeroBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF064E3B), // Deep Forest Emerald
            Color(0xFF047857), // Rich Emerald
            Color(0xFF0F5B2E), // Classic CLIKS Green
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: isMobile ? 20 : 28,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background decorative ambient circles
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            left: -35,
            bottom: -35,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Program Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, size: 12, color: Color(0xFFFBBF24)),
                    SizedBox(width: 6),
                    Text(
                      'CLIKS PARTNER REWARDS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3D-styled Gold Gift Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.gift, color: Color(0xFF78350F), size: 32),
              ),
              const SizedBox(height: 16),

              // Headline
              Text(
                'Refer & Earn Premium',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 22 : 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: const Text(
                  'Introduce fellow founders, merchants & business associates to CLIKS. For every active workspace initialized, collect instant reward points credited directly to your wallet!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reward Highlight Capsule (Wrap prevents any horizontal overflow on small screens)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.45)),
                ),
                child: const Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Icon(LucideIcons.coins, color: Color(0xFFFBBF24), size: 15),
                    Text(
                      'Earn 500 Points',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'per activation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Metrics Row
  // ---------------------------------------------------------------------------
  Widget _buildMetricsRow(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Total Shared',
            value: '12 Invites',
            icon: LucideIcons.send,
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            title: 'Successful',
            value: '8 Active',
            icon: LucideIcons.users,
            iconColor: const Color(0xFF059669),
            bgColor: const Color(0xFFECFDF5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            title: 'Points Earned',
            value: '4,000 Pts',
            icon: LucideIcons.coins,
            iconColor: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Referral Action Card
  // ---------------------------------------------------------------------------
  Widget _buildReferralActionCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Label & Active Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'YOUR EXCLUSIVE REFERRAL LINK',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.check, size: 11, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Link Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.link, size: 16, color: Color(0xFF059669)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    _referralLink,
                    style: TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copyToClipboard(_referralLink, isCode: false),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isLinkCopied ? const Color(0xFF059669) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isLinkCopied ? LucideIcons.check : LucideIcons.copy,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isLinkCopied ? 'Copied' : 'Copy',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Referral Code Pill Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'Referral Code: ',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: _referralCode,
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _copyToClipboard(_referralCode, isCode: true),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCodeCopied ? LucideIcons.check : LucideIcons.copy,
                        size: 12,
                        color: _isCodeCopied ? const Color(0xFF059669) : const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isCodeCopied ? 'Copied' : 'Copy Code',
                        style: TextStyle(
                          color: _isCodeCopied ? const Color(0xFF059669) : const Color(0xFF2563EB),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Full-width Primary Copy & Share Action Buttons
          isMobile
              ? Column(
                  children: [
                    _buildPrimaryActionButton(
                      label: _isLinkCopied ? 'Referral Link Copied!' : 'Copy Referral URL',
                      icon: _isLinkCopied ? LucideIcons.check : LucideIcons.copy,
                      bgColor: _isLinkCopied ? const Color(0xFF059669) : const Color(0xFF0F172A),
                      onTap: () => _copyToClipboard(_referralLink, isCode: false),
                    ),
                    const SizedBox(height: 10),
                    _buildSecondaryActionButton(
                      label: 'Copy Complete Invite Message',
                      icon: LucideIcons.share2,
                      onTap: _shareCustomMessage,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildPrimaryActionButton(
                        label: _isLinkCopied ? 'Link Copied!' : 'Copy Referral URL',
                        icon: _isLinkCopied ? LucideIcons.check : LucideIcons.copy,
                        bgColor: _isLinkCopied ? const Color(0xFF059669) : const Color(0xFF0F172A),
                        onTap: () => _copyToClipboard(_referralLink, isCode: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSecondaryActionButton(
                        label: 'Copy Complete Invite Message',
                        icon: LucideIcons.share2,
                        onTap: _shareCustomMessage,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: const Color(0xFF334155)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. How It Works (3 Steps)
  // ---------------------------------------------------------------------------
  Widget _buildHowItWorksSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOW IT WORKS',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 14),

          _buildStepRow(
            stepNumber: '01',
            title: 'Share your exclusive link or code',
            subtitle: 'Send your referral link to friends, founders, and fellow businesses.',
            icon: LucideIcons.users,
            iconColor: const Color(0xFF2563EB),
            badgeBg: const Color(0xFFEFF6FF),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 19),
            child: SizedBox(height: 14, child: VerticalDivider(width: 2, color: Color(0xFFE2E8F0))),
          ),
          _buildStepRow(
            stepNumber: '02',
            title: 'They join and initialize their account',
            subtitle: 'Your referral signs up and sets up their business profile on CLIKS.',
            icon: LucideIcons.rocket,
            iconColor: const Color(0xFFD97706),
            badgeBg: const Color(0xFFFFFBEB),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 19),
            child: SizedBox(height: 14, child: VerticalDivider(width: 2, color: Color(0xFFE2E8F0))),
          ),
          _buildStepRow(
            stepNumber: '03',
            title: 'Collect 500 Points instantly in your wallet',
            subtitle: 'Points are immediately credited to redeem for premium quotas and perks.',
            icon: LucideIcons.sparkles,
            iconColor: const Color(0xFF059669),
            badgeBg: const Color(0xFFECFDF5),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color badgeBg,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.2)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'STEP $stepNumber',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Direct Sharing Channels
  // ---------------------------------------------------------------------------
  Widget _buildDirectShareCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DIRECT SHARING CHANNELS',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSharePill(
                label: 'Copy Draft Invite',
                icon: LucideIcons.copy,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                onTap: _shareCustomMessage,
              ),
              _buildSharePill(
                label: 'WhatsApp / Chat',
                icon: LucideIcons.send,
                iconColor: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                onTap: _shareCustomMessage,
              ),
              _buildSharePill(
                label: 'Email Invite',
                icon: LucideIcons.mail,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFFFBEB),
                onTap: _shareCustomMessage,
              ),
              _buildSharePill(
                label: 'Quick Copy URL',
                icon: LucideIcons.link,
                iconColor: const Color(0xFF475569),
                bgColor: const Color(0xFFF1F5F9),
                onTap: () => _copyToClipboard(_referralLink, isCode: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSharePill({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Assurance Footer Banner
  // ---------------------------------------------------------------------------
  Widget _buildAssuranceBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.shieldCheck, color: Color(0xFF059669), size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Reward points never expire and can be redeemed in your Wallet anytime for premium tools, subscription waivers, and founder quotas.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
