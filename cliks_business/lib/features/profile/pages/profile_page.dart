import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../core/navigation/navigation_provider.dart';

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

  String _currentUsername = 'ravikumarlaptop';
  String _currentEmail = 'ravikumarlaptop@bnxmail.com';

  bool _isExpanded = false;
  late List<Map<String, dynamic>> _accounts;

  @override
  void initState() {
    super.initState();
    _accounts = [
      {'username': _currentUsername, 'email': _currentEmail, 'icon': LucideIcons.user, 'color': const Color(0xFF1565C0)},
      {'username': 'cliks_admin', 'email': 'admin@cliks.business', 'icon': LucideIcons.userCheck, 'color': const Color(0xFF2E7D32)},
    ];
  }

  void _showAddAccountDialog() {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Multiple Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Enter new account username',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter email associated with account',
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
              final newUsername = usernameController.text.trim();
              final newEmail = emailController.text.trim();
              if (newUsername.isNotEmpty && newEmail.isNotEmpty) {
                setState(() {
                  _currentUsername = newUsername;
                  _currentEmail = newEmail;
                  _isExpanded = false; // Collapse after adding
                  // Add it if it doesn't exist
                  if (!_accounts.any((a) => a['username'] == newUsername)) {
                    _accounts.add({
                      'username': newUsername,
                      'email': newEmail,
                      'icon': LucideIcons.user,
                      'color': Colors.purple,
                    });
                  }
                });
                Navigator.pop(ctx);
                AppSnackbar.show(
                  context,
                  "Account '$newUsername' added and set as active.",
                  type: SnackType.success,
                );
              } else {
                AppSnackbar.show(
                  context,
                  "Please enter both username and email.",
                  type: SnackType.error,
                );
              }
            },
            child: const Text('Add & Switch'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final paddingVal = isMobile ? 16.0 : 32.0;

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
              _buildProfileHeader(isMobile).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
              
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: paddingVal, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1, thickness: 1, color: AppColors.border),
                        const SizedBox(height: 12),

                        // Created On Info Card
                        _buildCreatedOnCard().animate().fadeIn(duration: 450.ms, delay: 50.ms),

                        // Security Protocols Section
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
                        ).animate().fadeIn(duration: 450.ms, delay: 100.ms),

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
                        ).animate().fadeIn(duration: 450.ms, delay: 150.ms),

                        _buildCardTile(
                          icon: LucideIcons.lock,
                          title: 'Update Corporate Password',
                          subtitle: 'Securely rotate access credentials',
                          onTap: () => _showUpdatePasswordDialog(context),
                          trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
                        ).animate().fadeIn(duration: 450.ms, delay: 200.ms),

                        // Notifications Section
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
                        ).animate().fadeIn(duration: 450.ms, delay: 250.ms),

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
                        ).animate().fadeIn(duration: 450.ms, delay: 300.ms),

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
                        ).animate().fadeIn(duration: 450.ms, delay: 350.ms),

                        // System & Support Section
                        _buildSectionHeader('SYSTEM & SUPPORT'),
                        _buildCardTile(
                          icon: LucideIcons.settings,
                          title: 'Settings',
                          subtitle: 'Manage configurations and app settings',
                          onTap: () {
                            ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.profile, AppRoute.settings);
                          },
                          trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
                        ).animate().fadeIn(duration: 450.ms, delay: 400.ms),

                        _buildCardTile(
                          icon: LucideIcons.helpCircle,
                          title: 'Help & Support',
                          subtitle: 'View FAQs and contact support',
                          onTap: () {
                            ref.read(navigationProvider.notifier).setModuleAndRoute(AppModule.profile, AppRoute.help);
                          },
                          trailing: const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.secondaryText),
                        ).animate().fadeIn(duration: 450.ms, delay: 450.ms),

                        const SizedBox(height: 24),

                        // Terminate Secure Session Button
                        _buildTerminateButton(context).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                        const SizedBox(height: 32),

                        // Footer Version Label
                        const Center(
                          child: Text(
                            'CLIKS Business v2.4.0 • Enterprise Core',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms, delay: 450.ms),
                        const SizedBox(height: 32),
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

  Widget _buildProfileHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24, 
        isMobile ? 12 : 16,
        isMobile ? 16 : 24, 
        isMobile ? 20 : 28
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, Color(0xFF0F5B2E)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(LucideIcons.user, size: 32, color: AppColors.primaryGreen),
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
                  Text(
                    _currentUsername,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
            _currentEmail,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                ..._accounts.map((acc) {
                  final isSelected = acc['username'] == _currentUsername;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentUsername = acc['username'] as String;
                        _currentEmail = acc['email'] as String;
                        _isExpanded = false;
                      });
                      AppSnackbar.show(
                        context,
                        "Switched to account '${acc['username']}'.",
                        type: SnackType.success,
                      );
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
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isSelected ? Colors.white : Colors.white24,
                            child: Icon(
                              acc['icon'] as IconData,
                              size: 16,
                              color: isSelected ? AppColors.primaryGreen : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acc['username'] as String,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  acc['email'] as String,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 11,
                                  ),
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
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              content: const Text('Are you sure you want to disconnect from the active business session?'),
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
                      "Session terminated successfully.",
                      type: SnackType.success,
                    );
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

