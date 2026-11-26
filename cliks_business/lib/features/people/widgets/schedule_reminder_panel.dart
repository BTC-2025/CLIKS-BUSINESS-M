import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import '../../../data/models/people_models.dart';
import '../providers/people_providers.dart';

class ScheduleReturnReminderPanel extends ConsumerStatefulWidget {
  const ScheduleReturnReminderPanel({super.key});

  @override
  ConsumerState<ScheduleReturnReminderPanel> createState() => _ScheduleReturnReminderPanelState();
}

class _ScheduleReturnReminderPanelState extends ConsumerState<ScheduleReturnReminderPanel> {
  PersonContact? _selectedContact;
  final TextEditingController _titleController = TextEditingController(text: 'Repayment of Friendly Loan');
  final TextEditingController _capValueController = TextEditingController(text: '0.00');
  final TextEditingController _dateController = TextEditingController(text: '2026-12-15');
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(peopleProvider).contacts.isEmpty) {
        ref.read(peopleProvider.notifier).loadContacts();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _capValueController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 768;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;

    final contacts = ref.watch(peopleProvider).contacts;

    final panelContent = Container(
      constraints: BoxConstraints(
        maxWidth: isMobile ? double.infinity : 550,
        maxHeight: isMobile ? screenHeight * 0.75 : 560,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isMobile
            ? const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              )
            : BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMobile) _buildDragHandle(),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
            child: _buildHeader('Schedule Return Reminder'),
          ),
          const Divider(height: 16, color: AppColors.border),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Dispatch to Contact *'),
                  _buildContactDropdown(contacts),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Reminder Title *'),
                            _buildTextField(_titleController, 'Reminder Title'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Cap Value *'),
                            _buildTextField(
                              _capValueController,
                              '0.00',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                const CurrencyInputFormatter(integerDigits: 12, decimalDigits: 2),
                                LengthLimitingTextInputFormatter(15),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Execution Maturity Date *'),
                  _buildDateField(_dateController, 'Select date...'),
                  const SizedBox(height: 32),
                  _buildActionButton('Commit Reminder Flow', AppColors.darkGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
        child: isMacOS
            ? panelContent
            : panelContent.animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
              ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        IconButton(
          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.people),
          icon: const Icon(LucideIcons.x, size: 20, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildContactDropdown(List<PersonContact> contacts) {
    if (contacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'No contacts enrolled yet. Add contacts from People Network first.',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
      );
    }

    final selected = _selectedContact ?? contacts.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PersonContact>(
          value: contacts.contains(selected) ? selected : contacts.first,
          isExpanded: true,
          items: contacts.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                '${c.name} (${c.roleType})',
                style: const TextStyle(fontSize: 13, color: AppColors.darkText),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedContact = val);
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 13, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 15)),
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
          );
          if (picked != null) {
            controller.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
        style: const TextStyle(fontSize: 13, color: AppColors.darkText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
          suffixIcon: const Icon(LucideIcons.calendar, size: 16, color: AppColors.secondaryText),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting
            ? null
            : () async {
                final contacts = ref.read(peopleProvider).contacts;
                if (contacts.isEmpty) {
                  AppSnackbar.show(
                    context,
                    'Please add a contact before scheduling reminders',
                    type: SnackType.warning,
                  );
                  return;
                }

                final target = _selectedContact ?? contacts.first;
                final memo = _titleController.text.trim();
                final val = double.tryParse(_capValueController.text.replaceAll(',', '').trim()) ?? 0.0;
                final dateStr = _dateController.text.trim();

                if (memo.isEmpty) {
                  AppSnackbar.show(context, 'Please enter a reminder title', type: SnackType.warning);
                  return;
                }

                if (val <= 0) {
                  AppSnackbar.show(context, 'Please enter a valid cap amount greater than ₹0', type: SnackType.warning);
                  return;
                }

                if (val > kMaxAllowedAmount) {
                  AppSnackbar.show(
                    context,
                    'Cap Value cannot exceed $kMaxAllowedAmountText',
                    type: SnackType.warning,
                  );
                  return;
                }

                final req = CreateRepaymentAlertRequest(
                  contactId: target.id,
                  targetContact: target.name,
                  claimCap: val,
                  maturityDate: dateStr.isNotEmpty ? dateStr : '2026-12-15',
                  memoLabel: memo,
                  status: 'Pending',
                );

                setState(() => _isSubmitting = true);
                try {
                  await ref.read(peopleProvider.notifier).createRepaymentAlert(req);
                  if (mounted) {
                    AppSnackbar.show(
                      context,
                      "Repayment reminder scheduled for '${target.name}'!",
                      type: SnackType.success,
                    );
                    ref.read(navigationProvider.notifier).setRoute(AppRoute.people);
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _isSubmitting = false);
                    AppSnackbar.show(context, e.toString(), type: SnackType.error);
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
