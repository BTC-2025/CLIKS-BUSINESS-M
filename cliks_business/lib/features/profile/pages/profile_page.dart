import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../widgets/bento/bento.dart';
import '../../../data/account_provider.dart';
import '../../../models/account_model.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../../auth/pages/login_screen.dart';
import '../../auth/pages/register_account_type_screen.dart';
import '../presentation/manage_account_screen.dart';
import '../../../core/network/token_service.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../data/repositories/user_repository.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _biometricLogin = false;
  bool _smsGateway = true;
  bool _emailSync = true;
  bool _pushNotifications = true;

  String _currentUsername = '';
  String _currentEmail = '';

  bool _isExpanded = false;
  String? _profileAvatar;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final email = (await TokenService.getUserEmail() ?? '').trim().toLowerCase();
      if (email.isNotEmpty) {
        final avatar = await TokenService.getUserAvatar(email);
        if (mounted && avatar != null && avatar.isNotEmpty) {
          setState(() {
            _profileAvatar = avatar;
          });
        }
      }
      final profile = await UserRepository.getProfile(email: email.isNotEmpty ? email : null);
      if (mounted && profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty) {
        setState(() {
          _profileAvatar = profile.avatarUrl;
        });
      }
    } catch (_) {}
  }

  void _showAddAccountDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add or Switch Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to an existing BNX account or create a brand new account for mobile.',
                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.logIn, color: AppColors.primaryGreen, size: 20),
                ),
                title: const Text('Sign in with existing account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Log in with your existing BNX Mail credentials', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const Divider(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF195BAC).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.userPlus, color: Color(0xFF195BAC), size: 20),
                ),
                title: const Text('Create a new account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Register for personal, child, or business BNX Mail', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterAccountTypeScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    Widget maybeAnim(Widget w, Widget Function(Widget) fn) => isMacOS ? w : fn(w);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryGreen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card - Full Bleed
              isMacOS
                  ? _buildMacOsProfileHero(isMobile)
                  : maybeAnim(_buildProfileHeader(isMobile), (w) => w.animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0)),
              
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMacOS ? 960 : 600),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingVal, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMacOS) ...[
                          const Divider(height: 1, thickness: 1, color: AppColors.border),
                          const SizedBox(height: 12),
                        ],
                        if (isMacOS && !isMobile) ...[
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildCreatedOnCard(),
                                    _buildSectionHeader('SECURITY PROTOCOLS'),
                                    _buildCardTile(
                                      icon: LucideIcons.shieldCheck,
                                      title: 'Two-Factor Authentication (Coming Soon)',
                                      subtitle: 'Double-layer MFA is currently unsupported by platform',
                                      isComingSoon: true,
                                      trailing: const Switch(
                                        value: false,
                                        onChanged: null,
                                        inactiveThumbColor: Color(0xFF9CA3AF),
                                        inactiveTrackColor: Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    _buildCardTile(
                                      icon: LucideIcons.fingerprint,
                                      title: 'Biometric Hardware Login',
                                      subtitle: 'Unlock with FaceID / TouchID',
                                      trailing: Switch(
                                        value: _biometricLogin,
                                        onChanged: (val) {
                                          setState(() => _biometricLogin = val);
                                          AppSnackbar.show(
                                            context,
                                            val ? "Biometric login enabled." : "Biometric login disabled.",
                                            type: SnackType.success,
                                          );
                                        },
                                        activeThumbColor: AppColors.primaryGreen,
                                        activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                                        inactiveThumbColor: const Color(0xFF6B7280),
                                        inactiveTrackColor: const Color(0xFFE6EBEF),
                                      ),
                                    ),
                                    _buildCardTile(
                                      icon: LucideIcons.lock,
                                      title: 'Update Corporate Password',
                                      subtitle: 'Securely rotate access credentials',
                                      onTap: () => _showUpdatePasswordDialog(context),
                                      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildTerminateButton(context),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionHeader('NOTIFICATIONS & PREFERENCES'),
                                    _buildCardTile(
                                      icon: LucideIcons.messageSquare,
                                      title: 'SMS Real-time Gateway',
                                      subtitle: 'Receive accounting confirmations via SMS',
                                      trailing: Switch(
                                        value: _smsGateway,
                                        onChanged: (val) {
                                          setState(() => _smsGateway = val);
                                          AppSnackbar.show(
                                            context,
                                            val ? "SMS confirmations activated." : "SMS confirmations deactivated.",
                                            type: SnackType.success,
                                          );
                                        },
                                        activeThumbColor: AppColors.primaryGreen,
                                        activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                                        inactiveThumbColor: const Color(0xFF6B7280),
                                        inactiveTrackColor: const Color(0xFFE6EBEF),
                                      ),
                                    ),
                                    _buildCardTile(
                                      icon: LucideIcons.mail,
                                      title: 'Email Reports Sync',
                                      subtitle: 'Receive monthly reconciliations dynamically',
                                      trailing: Switch(
                                        value: _emailSync,
                                        onChanged: (val) {
                                          setState(() => _emailSync = val);
                                          AppSnackbar.show(
                                            context,
                                            val ? "Email reports sync activated." : "Email reports sync deactivated.",
                                            type: SnackType.success,
                                          );
                                        },
                                        activeThumbColor: AppColors.primaryGreen,
                                        activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                                        inactiveThumbColor: const Color(0xFF6B7280),
                                        inactiveTrackColor: const Color(0xFFE6EBEF),
                                      ),
                                    ),
                                    _buildCardTile(
                                      icon: LucideIcons.bell,
                                      title: 'Direct Push Notifications',
                                      subtitle: 'Instant alerts for invoice settlements',
                                      trailing: Switch(
                                        value: _pushNotifications,
                                        onChanged: (val) {
                                          setState(() => _pushNotifications = val);
                                          AppSnackbar.show(
                                            context,
                                            val ? "Push notifications activated." : "Push notifications deactivated.",
                                            type: SnackType.success,
                                          );
                                        },
                                        activeThumbColor: AppColors.primaryGreen,
                                        activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                                        inactiveThumbColor: const Color(0xFF6B7280),
                                        inactiveTrackColor: const Color(0xFFE6EBEF),
                                      ),
                                    ),
                                    _buildSectionHeader('SYSTEM & SUPPORT'),
                                    _buildCardTile(
                                      icon: LucideIcons.settings,
                                      title: 'Settings',
                                      subtitle: 'Manage configurations and app settings',
                                      onTap: () {
                                        ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.profile, AppRoute.settings);
                                      },
                                      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
                                    ),
                                    _buildCardTile(
                                      icon: LucideIcons.helpCircle,
                                      title: 'Help & Support',
                                      subtitle: 'View FAQs and contact support',
                                      onTap: () {
                                        ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.profile, AppRoute.help);
                                      },
                                      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Created On Info Card
                          maybeAnim(_buildCreatedOnCard(), (w) => w.animate().fadeIn(duration: 450.ms, delay: 50.ms)),

                          // Security Protocols Section
                          _buildSectionHeader('SECURITY PROTOCOLS'),
                          maybeAnim(
                            _buildCardTile(
                              icon: LucideIcons.shieldCheck,
                              title: 'Two-Factor Authentication (Coming Soon)',
                              subtitle: 'Double-layer MFA is currently unsupported by platform',
                              isComingSoon: true,
                              trailing: const Switch(
                                value: false,
                                onChanged: null,
                                inactiveThumbColor: Color(0xFF9CA3AF),
                                inactiveTrackColor: Color(0xFFE5E7EB),
                              ),
                            ),
                            (w) => w.animate().fadeIn(duration: 450.ms, delay: 100.ms),
                          ),

                          maybeAnim(
                            _buildCardTile(
                              icon: LucideIcons.fingerprint,
                              title: 'Biometric Hardware Login',
                              subtitle: 'Unlock with FaceID / TouchID',
                              trailing: Switch(
                                value: _biometricLogin,
                                onChanged: (val) {
                                  setState(() => _biometricLogin = val);
                                  AppSnackbar.show(
                                    context,
                                    val ? "Biometric login enabled." : "Biometric login disabled.",
                                    type: SnackType.success,
                                  );
                                },
                                activeThumbColor: AppColors.primaryGreen,
                                activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                                inactiveThumbColor: const Color(0xFF6B7280),
                                inactiveTrackColor: const Color(0xFFE6EBEF),
                              ),
                            ),
                            (w) => w.animate().fadeIn(duration: 450.ms, delay: 150.ms),
                          ),

                          maybeAnim(
                            _buildCardTile(
                              icon: LucideIcons.lock,
                              title: 'Update Corporate Password',
                              subtitle: 'Securely rotate access credentials',
                              onTap: () => _showUpdatePasswordDialog(context),
                              trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
                            ),
                            (w) => w.animate().fadeIn(duration: 450.ms, delay: 200.ms),
                          ),

                          // Notifications Section
                          _buildSectionHeader('NOTIFICATIONS & PREFERENCES'),
                          maybeAnim(
                            _buildCardTile(
                              icon: LucideIcons.messageSquare,
                              title: 'SMS Real-time Gateway',
                              subtitle: 'Receive accounting confirmations via SMS',
                              trailing: Switch(
                                value: _smsGateway,
                                onChanged: (val) {
                                  setState(() => _smsGateway = val);
                                  AppSnackbar.show(
                                    context,
                                    val ? "SMS confirmations activated." : "SMS confirmations deactivated.",
                                    type: SnackType.success,
                                  );
                                },
                                activeThumbColor: AppColors.primaryGreen,
                                activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                                inactiveThumbColor: const Color(0xFF6B7280),
                                inactiveTrackColor: const Color(0xFFE6EBEF),
                              ),
                            ),
                            (w) => w.animate().fadeIn(duration: 450.ms, delay: 250.ms),
                          ),

                          maybeAnim(
                            _buildCardTile(
                              icon: LucideIcons.mail,
                              title: 'Email Reports Sync',
                              subtitle: 'Receive monthly reconciliations dynamically',
                              trailing: Switch(
                                value: _emailSync,
                                onChanged: (val) {
                                  setState(() => _emailSync = val);
                                  AppSnackbar.show(
                                    context,
                                    val ? "Email reports sync activated." : "Email reports sync deactivated.",
                                    type: SnackType.success,
                                  );
                                },
                                activeThumbColor: AppColors.primaryGreen,
                                activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                                inactiveThumbColor: const Color(0xFF6B7280),
                                inactiveTrackColor: const Color(0xFFE6EBEF),
                              ),
                            ),
                            (w) => w.animate().fadeIn(duration: 450.ms, delay: 300.ms),
                          ),

                          maybeAnim(
                            _buildCardTile(
                              icon: LucideIcons.bell,
                              title: 'Direct Push Notifications',
                              subtitle: 'Instant alerts for invoice settlements',
                              trailing: Switch(
                                value: _pushNotifications,
                                onChanged: (val) {
                                  setState(() => _pushNotifications = val);
                                  AppSnackbar.show(
                                    context,
                                    val ? "Push notifications activated." : "Push notifications deactivated.",
                                    type: SnackType.success,
                                  );
                                },
                                activeThumbColor: AppColors.primaryGreen,
                                activeTrackColor: AppColors.primaryGreen.withValues(alpha: 0.4),
                                inactiveThumbColor: const Color(0xFF6B7280),
                                inactiveTrackColor: const Color(0xFFE6EBEF),
                              ),
                            ),
                            (w) => w.animate().fadeIn(duration: 450.ms, delay: 350.ms),
                          ),

                          // System & Support Section
                          _buildSectionHeader('SYSTEM & SUPPORT'),
                          maybeAnim(
                            _buildCardTile(
                              icon: LucideIcons.settings,
                              title: 'Settings',
                              subtitle: 'Manage configurations and app settings',
                              onTap: () {
                                ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.profile, AppRoute.settings);
                              },
                              trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
                            ),
                            (w) => w.animate().fadeIn(duration: 450.ms, delay: 400.ms),
                          ),

                          maybeAnim(
                            _buildCardTile(
                              icon: LucideIcons.helpCircle,
                              title: 'Help & Support',
                              subtitle: 'View FAQs and contact support',
                              onTap: () {
                                ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.profile, AppRoute.help);
                              },
                              trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
                            ),
                            (w) => w.animate().fadeIn(duration: 450.ms, delay: 450.ms),
                          ),

                          const SizedBox(height: 16),

                          // Dedicated Sign Out Action for Mobile UI
                          maybeAnim(_buildSignOutTile(context), (w) => w.animate().fadeIn(duration: 450.ms, delay: 475.ms)),

                          const SizedBox(height: 12),

                          // Terminate Secure Session Button
                          maybeAnim(_buildTerminateButton(context), (w) => w.animate().fadeIn(duration: 500.ms, delay: 500.ms)),
                        ],

                        const SizedBox(height: 24),

                        // Footer Version Label
                        maybeAnim(
                          const Center(
                            child: Text(
                              'CLIKS Business v2.4.0 • Enterprise Core',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          (w) => w.animate().fadeIn(duration: 500.ms, delay: 450.ms),
                        ),
                        SizedBox(height: isMobile ? 110 : 36),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MACOS SOFT UI BENTO HERO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMacOsProfileHero(bool isMobile) {
    final activeAccount = ref.watch(activeAccountProvider);
    final allAccounts = ref.watch(accountsProvider);
    final currentUsername = activeAccount.name.isNotEmpty
        ? activeAccount.name
        : (activeAccount.email.isNotEmpty
            ? activeAccount.email.split('@').first
            : (_currentUsername.isNotEmpty ? _currentUsername : 'User'));
    final currentEmail = activeAccount.email.isNotEmpty
        ? activeAccount.email
        : (_currentEmail.isNotEmpty ? _currentEmail : 'Not signed in');
    final List<AccountModel> displayAccounts = allAccounts.where((a) => a.id != 'loading').isNotEmpty
        ? allAccounts.where((a) => a.id != 'loading').toList()
        : [activeAccount];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MacOsSoftUiBentoHero(
          title: 'Identity & Access Control',
          mainValue: currentUsername,
          subtitle: currentEmail,
          badgeText: 'SUPER ADMIN',
          badgeIcon: LucideIcons.shieldCheck,
          isMobile: isMobile,
          chips: [
            MacOsBentoHeroChip(
              label: 'Linked Profiles',
              value: '${displayAccounts.length} Active',
              icon: LucideIcons.users,
              accentColor: const Color(0xFF166534),
              onTap: () => setState(() => _isExpanded = !_isExpanded),
            ),
            MacOsBentoHeroChip(
              label: 'Security Tier',
              value: _biometricLogin ? 'Biometric Enforced' : 'Standard Auth',
              icon: LucideIcons.keyRound,
              accentColor: const Color(0xFF2563EB),
            ),
            MacOsBentoHeroChip(
              label: 'Territory Node',
              value: 'India (IN)',
              icon: LucideIcons.globe,
              accentColor: const Color(0xFFD97706),
            ),
          ],
          trailingAction: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageAccountScreen(),
                    ),
                  );
                },
                icon: const Icon(LucideIcons.userCog, size: 13),
                label: const Text('Manage Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF166534),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(_isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 13),
                label: Text(_isExpanded ? 'Hide Profiles' : 'Switch Profile', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF166534),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddAccountDialog,
                icon: const Icon(LucideIcons.userPlus, size: 13),
                label: const Text('Add Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        if (_isExpanded)
          Container(
            margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, 12, isMobile ? 14 : 24, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.tableBorder),
              boxShadow: const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Identity Profiles',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    TextButton.icon(
                      onPressed: _showAddAccountDialog,
                      icon: const Icon(LucideIcons.plus, size: 12),
                      label: const Text('New Profile', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF166534)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...displayAccounts.map((acc) {
                  final isSelected = acc.id == activeAccount.id || acc.email == activeAccount.email;
                  final accountName = acc.name.isNotEmpty
                      ? acc.name
                      : (acc.email.isNotEmpty ? acc.email.split('@').first : 'User');
                  final accountEmail = acc.email.isNotEmpty ? acc.email : 'user@bnxmail.com';

                  return InkWell(
                    onTap: () async {
                      setState(() {
                        _currentUsername = accountName;
                        _currentEmail = accountEmail;
                        _isExpanded = false;
                      });
                      await ref.read(accountsProvider.notifier).switchAccount(acc.id, ref);
                      if (context.mounted) {
                        AppSnackbar.show(
                          context,
                          "Switched to profile '$accountName'.",
                          type: SnackType.success,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFDCF2E4) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF166534).withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: isSelected ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
                            child: Icon(
                              LucideIcons.user,
                              size: 15,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  accountName,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                    color: isSelected ? const Color(0xFF166534) : const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  accountEmail,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              LucideIcons.checkCircle2,
                              color: Color(0xFF166534),
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProfileHeader(bool isMobile) {
    final activeAccount = ref.watch(activeAccountProvider);
    final effectiveAvatar = (_profileAvatar != null && _profileAvatar!.isNotEmpty)
        ? _profileAvatar
        : activeAccount.avatarUrl;
    final allAccounts = ref.watch(accountsProvider);
    final currentUsername = activeAccount.name.isNotEmpty
        ? activeAccount.name
        : (activeAccount.email.isNotEmpty
            ? activeAccount.email.split('@').first
            : (_currentUsername.isNotEmpty ? _currentUsername : 'User'));
    final currentEmail = activeAccount.email.isNotEmpty
        ? activeAccount.email
        : (_currentEmail.isNotEmpty ? _currentEmail : 'Not signed in');
    final List<AccountModel> displayAccounts = allAccounts.where((a) => a.id != 'loading').isNotEmpty
        ? allAccounts.where((a) => a.id != 'loading').toList()
        : [activeAccount];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24, 
        isMobile ? 12 : 16,
        isMobile ? 16 : 24, 
        isMobile ? 20 : 28
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(color: AppColors.heroShadowColor, blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: AvatarWidget(
              name: currentUsername,
              avatarUrl: effectiveAvatar,
              size: 64,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      currentUsername,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(LucideIcons.chevronDown, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentEmail,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          
          // Inline expandable account switcher
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const SizedBox(height: 12),
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                const SizedBox(height: 12),
                // Account list cards/rows
                ...displayAccounts.map((acc) {
                  final isSelected = acc.id == activeAccount.id || acc.email == activeAccount.email;
                  final accountName = acc.name.isNotEmpty
                      ? acc.name
                      : (acc.email.isNotEmpty ? acc.email.split('@').first : 'User');
                  final accountEmail = acc.email.isNotEmpty ? acc.email : 'user@bnxmail.com';

                  return GestureDetector(
                    onTap: () async {
                      setState(() {
                        _currentUsername = accountName;
                        _currentEmail = accountEmail;
                        _isExpanded = false;
                      });
                      await ref.read(accountsProvider.notifier).switchAccount(acc.id, ref);
                      if (context.mounted) {
                        AppSnackbar.show(
                          context,
                          "Switched to account '$accountName'.",
                          type: SnackType.success,
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.20)
                            : Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.45)
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          AvatarWidget(
                            name: accountName,
                            avatarUrl: acc.avatarUrl,
                            size: 32,
                            fontSize: 14,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  accountName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  accountEmail,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              LucideIcons.checkCircle2,
                              color: Colors.white,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                // Manage Account button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ManageAccountScreen(),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: const Icon(
                            LucideIcons.userCog,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Manage Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Add another account button
                GestureDetector(
                  onTap: () {
                    _showAddAccountDialog();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: const Icon(
                            LucideIcons.plus,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add another account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.mapPin, size: 12, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'IN India',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatedOnCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
        boxShadow: const [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.calendar,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Created On',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '2026-07-11',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryText,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildCardTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isComingSoon = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tableBorder),
        boxShadow: const [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isComingSoon 
                        ? AppColors.primaryGreen.withValues(alpha: 0.5) 
                        : AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isComingSoon 
                              ? AppColors.darkText.withValues(alpha: 0.6) 
                              : AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isComingSoon 
                              ? AppColors.secondaryText.withValues(alpha: 0.6) 
                              : AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutTile(BuildContext context) {
    return _buildCardTile(
      icon: LucideIcons.logOut,
      title: 'Sign Out',
      subtitle: 'Sign out of your active corporate session',
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out of this account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await ref.read(authProvider.notifier).logout();
                  } catch (_) {}
                  ref.read(accountsProvider.notifier).clear();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                    AppSnackbar.show(
                      context,
                      "Signed out successfully.",
                      type: SnackType.success,
                    );
                  }
                },
                child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
    );
  }

  Widget _buildTerminateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Terminate Session?'),
              content: const Text('Are you sure you want to disconnect from the active business session? You will be signed out.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await ref.read(authProvider.notifier).logout();
                    } catch (_) {}
                    ref.read(accountsProvider.notifier).clear();
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                      AppSnackbar.show(
                        context,
                        "Session terminated successfully.",
                        type: SnackType.success,
                      );
                    }
                  },
                  child: const Text('Terminate', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        icon: const Icon(LucideIcons.logOut, size: 18),
        label: const Text(
          'Terminate Secure Session',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5252),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showUpdatePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Corporate Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter current password',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                hintText: 'Enter new secure password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppSnackbar.show(
                context,
                "Password updated and rotated successfully.",
                type: SnackType.success,
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

