import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';

class ScheduleReturnReminderPanel extends ConsumerStatefulWidget {
  const ScheduleReturnReminderPanel({super.key});

  @override
  ConsumerState<ScheduleReturnReminderPanel> createState() => _ScheduleReturnReminderPanelState();
}

class _ScheduleReturnReminderPanelState extends ConsumerState<ScheduleReturnReminderPanel> {
  String _selectedContact = 'Select contact...';
  final TextEditingController _titleController = TextEditingController(text: 'Repayment of Friendly Loan');
  final TextEditingController _capValueController = TextEditingController(text: '0.00');
  final TextEditingController _dateController = TextEditingController(text: '17-07-2026');

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 550,
            maxHeight: isMobile ? screenHeight * 0.65 : 520,
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
                      _buildLabel('Dispatch to Contact'),
                      _buildDropdown(
                        ['Select contact...', 'Acme Corp', 'Wayne Enterprises', 'Rahul Dev'],
                        _selectedContact,
                        (val) => setState(() => _selectedContact = val!),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Reminder Title'),
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
                                _buildLabel('Cap Value'),
                                _buildTextField(_capValueController, '0.00', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      _buildLabel('Execution Maturity Date'),
                      _buildDateField(_dateController, 'Select date...'),
                      
                      const SizedBox(height: 32),
                      _buildActionButton('Commit Reminder Flow', AppColors.darkGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 400.ms),
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF004D40),
            ),
          ),
        ),
        IconButton(
          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.people),
          icon: const Icon(LucideIcons.x, size: 18, color: AppColors.secondaryText),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 9, 
          fontWeight: FontWeight.bold, 
          color: Colors.grey.shade600, 
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, ValueChanged<String?> onChanged) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 13, color: AppColors.darkText)),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.secondaryText),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            setState(() {
              controller.text = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
            });
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
        onPressed: () {
          ref.read(navigationProvider.notifier).setRoute(AppRoute.people);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
