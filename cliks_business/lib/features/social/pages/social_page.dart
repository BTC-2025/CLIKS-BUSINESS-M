import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/buttons/app_buttons.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../widgets/forms/app_text_field.dart';
import '../../../services/location_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/meetup_schedule_dialog.dart';

class SocialPage extends ConsumerWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final paddingVal = isMobile ? AppSpacing.lg : AppSpacing.xxxl;
    final locState = ref.watch(locationStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(paddingVal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xxl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.blue, Color(0xFF1E40AF)], // Premium Blue gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.lg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: AppRadius.round,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.globe, color: Colors.white, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'BUSINESS NETWORKING HUB',
                          style: AppTextStyles.overline.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Founders Meetup & Executive Events',
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: isMobile ? 22 : 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _LocationSelector(),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => const MeetupScheduleDialog(),
                              );
                            },
                            icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.blue),
                            label: const Text(
                              'Schedule Board',
                              style: TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.blue, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const _LocationSelector(),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const MeetupScheduleDialog(),
                            );
                          },
                          icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.blue),
                          label: const Text(
                            'Schedule Board',
                            style: TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.blue, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
            SizedBox(height: AppSpacing.xxl),
            
            // Tabs & Search
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _CategoryTabs(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(LucideIcons.search, size: 18),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.sm,
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.sm,
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms)
            else
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _CategoryTabs(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: const Icon(LucideIcons.search, size: 18),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.sm,
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.sm,
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            SizedBox(height: AppSpacing.xxl),

            // Active location tag displaying city
            if (locState.location != null)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 14, color: AppColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Showing events near ${locState.location!.city}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Events Grid
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 3;
                if (constraints.maxWidth < 600) {
                  crossAxisCount = 1;
                } else if (constraints.maxWidth < 950) {
                  crossAxisCount = 2;
                }
                
                final double itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount;
                final double aspectRatio = itemWidth / 415;
 
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => const EventCard()
                      .animate(delay: (index * 80).ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSelector extends ConsumerWidget {
  const _LocationSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locState = ref.watch(locationStateProvider);
    final displayCity = locState.location?.city ?? 'Select Location';

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const _LocationDialog(),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: AppRadius.sm,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.mapPin, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                displayCity,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronDown, color: Colors.white70, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationDialog extends ConsumerStatefulWidget {
  const _LocationDialog();

  @override
  ConsumerState<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends ConsumerState<_LocationDialog> {
  final _searchController = TextEditingController();
  bool _searching = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleGps() async {
    setState(() {
      _searching = true;
      _errorMessage = null;
    });
    try {
      await ref.read(locationStateProvider.notifier).detectGPSLocation();
      final updatedState = ref.read(locationStateProvider);
      if (updatedState.errorMessage != null) {
        setState(() => _errorMessage = updatedState.errorMessage);
      } else {
        if (mounted) Navigator.pop(context);
        AppSnackbar.show(context, 'Location updated successfully!', type: SnackType.success);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to detect GPS location.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searching = true;
      _errorMessage = null;
    });
    try {
      final success = await ref
          .read(locationStateProvider.notifier)
          .searchAndSetLocation(query);
      if (success) {
        if (mounted) Navigator.pop(context);
        AppSnackbar.show(context, 'Location set to $query', type: SnackType.success);
      } else {
        final updatedState = ref.read(locationStateProvider);
        setState(() {
          _errorMessage = updatedState.errorMessage ?? 'Location not found.';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Search error: Unable to geocode.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change Location', style: AppTextStyles.h3),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Select location to see relevant executive founders meetups near you.',
              style: AppTextStyles.bodySmall,
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Search Input
            AppTextField(
              label: 'Search City or Country',
              hint: 'e.g. Chennai, Paris, California',
              controller: _searchController,
              prefixIcon: LucideIcons.search,
              suffixIcon: LucideIcons.arrowRight,
              onSuffixTap: _handleSearch,
              onEditingComplete: _handleSearch,
              enabled: !_searching,
            ),
            SizedBox(height: AppSpacing.md),
            
            // Or divider
            AppLabeledDivider(label: 'OR'),
            SizedBox(height: AppSpacing.md),

            // GPS button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Use GPS Live Location',
                leadingIcon: LucideIcons.locate,
                isLoading: _searching,
                variant: AppButtonVariant.outline,
                onPressed: _searching ? null : _handleGps,
              ),
            ),

            if (_errorMessage != null) ...[
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: AppColors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final selectedSocialCategoryProvider = StateProvider<String>((ref) => 'All Events');

class _CategoryTabs extends ConsumerWidget {
  const _CategoryTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedSocialCategoryProvider);
    final categories = ['All Events', 'Upcoming', 'Technology', 'Science', 'Finance', 'Workshops'];
    
    return Row(
      children: categories.map((cat) {
        final isSelected = cat == selectedCategory;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (val) {
              if (val) {
                ref.read(selectedSocialCategoryProvider.notifier).state = cat;
              }
            },
            backgroundColor: Colors.white,
            selectedColor: AppColors.darkText,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.secondaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: isSelected ? AppColors.darkText : AppColors.border),
          ),
        );
      }).toList(),
    );
  }
}
