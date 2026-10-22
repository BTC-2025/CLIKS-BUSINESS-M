import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../data/account_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../../auth/pages/login_screen.dart';
import '../../profile/presentation/manage_account_screen.dart';

final macosAccountMenuVisibleProvider = StateProvider<bool>((ref) => false);

class MacOSAccountMenuCard extends ConsumerWidget {
  const MacOSAccountMenuCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAccount = ref.watch(activeAccountProvider);
    final email = activeAccount.email.trim().isNotEmpty
        ? activeAccount.email.trim()
        : '';
    final username = email.contains('@')
        ? email.split('@').first
        : (activeAccount.name.isNotEmpty ? activeAccount.name : 'User');
    final initialLetter = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              // Avatar with camera badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D68BD),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initialLetter,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      LucideIcons.camera,
                      size: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Username & Email
              Text(
                username,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),

              // Make it Primary
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account is set as Primary.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        LucideIcons.checkCircle2,
                        size: 13,
                        color: Color(0xFF16A34A),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Make it Primary',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Manage your account button
              InkWell(
                onTap: () {
                  ref.read(macosAccountMenuVisibleProvider.notifier).state = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageAccountScreen(initialTab: 0),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        LucideIcons.user,
                        size: 13,
                        color: Color(0xFF374151),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Manage your account',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 8),

              // 1. Manage Branches
              _buildMenuItem(
                icon: LucideIcons.building2,
                title: 'Manage Branches',
                onTap: () {
                  ref.read(macosAccountMenuVisibleProvider.notifier).state = false;
                  ref.read(navigationProvider.notifier).setModuleAndRoute(
                        AppModule.books,
                        AppRoute.warehouse,
                      );
                },
              ),

              // 2. Manage SubIDs
              _buildMenuItem(
                icon: LucideIcons.users,
                title: 'Manage SubIDs',
                onTap: () {
                  ref.read(macosAccountMenuVisibleProvider.notifier).state = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageAccountScreen(initialTab: 3),
                    ),
                  );
                },
              ),

              // 3. Add another account
              _buildMenuItem(
                icon: LucideIcons.userPlus,
                title: 'Add another account',
                onTap: () {
                  ref.read(macosAccountMenuVisibleProvider.notifier).state = false;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),

              // 4. Sign out of all accounts
              _buildMenuItem(
                icon: LucideIcons.logOut,
                title: 'Sign out of all accounts',
                onTap: () async {
                  ref.read(macosAccountMenuVisibleProvider.notifier).state = false;
                  try {
                    await ref.read(authProvider.notifier).logout();
                  } catch (_) {}
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),

              const SizedBox(height: 12),

              // Sign out button (centered pill with subtle outline)
              InkWell(
                onTap: () async {
                  ref.read(macosAccountMenuVisibleProvider.notifier).state = false;
                  try {
                    await ref.read(authProvider.notifier).logout();
                    await AuthRepository.logoutSpecificAccount(email);
                  } catch (_) {}
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        LucideIcons.logOut,
                        size: 15,
                        color: Color(0xFFDC2626),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      hoverColor: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: const Color(0xFF4B5563),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
