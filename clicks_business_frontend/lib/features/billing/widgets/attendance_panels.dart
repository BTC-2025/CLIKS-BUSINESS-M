import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';

class ManualPunchPanel extends ConsumerStatefulWidget {
  const ManualPunchPanel({super.key});

  @override
  ConsumerState<ManualPunchPanel> createState() => _ManualPunchPanelState();
}

class _ManualPunchPanelState extends ConsumerState<ManualPunchPanel> {
  String _selectedEmployee = 'Select Employee';
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();
  final TextEditingController _lateDurationController = TextEditingController(text: '0');
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    _lateDurationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isNarrow = screenWidth < 480;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 600,
            maxHeight: screenHeight * 0.65,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _buildHeader('Log Manual Punch Entry'),
              ),
              const Divider(height: 16, color: AppColors.border),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Employee Name'),
                      _buildDropdown(['Select Employee', 'Rahul Dev', 'Michael Scott', 'Jim Halpert'], _selectedEmployee, (val) => setState(() => _selectedEmployee = val!)),
                      const SizedBox(height: 20),
                      
                      // Responsive row for times
                      Wrap(
                        spacing: 16,
                        runSpacing: 20,
                        children: [
                          _buildWrapField(
                            width: isNarrow ? double.infinity : (screenWidth - 80) / 2,
                            label: 'Check-In Time',
                            child: _buildTimeField(_checkInController, '--:--'),
                          ),
                          _buildWrapField(
                            width: isNarrow ? double.infinity : (screenWidth - 80) / 2,
                            label: 'Check-Out Time',
                            child: _buildTimeField(_checkOutController, '--:--'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Responsive row for duration and location
                      Wrap(
                        spacing: 16,
                        runSpacing: 20,
                        children: [
                          _buildWrapField(
                            width: isNarrow ? double.infinity : (screenWidth - 80) / 2,
                            label: 'Late Duration (Mins)',
                            child: _buildTextField(_lateDurationController, '0', keyboardType: TextInputType.number),
                          ),
                          _buildWrapField(
                            width: isNarrow ? double.infinity : (screenWidth - 80) / 2,
                            label: 'Check-In Location (Optional)',
                            child: _buildTextField(_locationController, 'Main Office, Mumbai'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      _buildActionButton('Settle Timesheet Punch', const Color(0xFFD63384)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
        ),
        IconButton(
          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.attendance),
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
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildWrapField({required double width, required String label, required Widget child}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller, String hint) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: true,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (time != null) controller.text = time.format(context);
              },
            ),
          ),
          const Icon(LucideIcons.clock, size: 14, color: AppColors.secondaryText),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.attendance),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}

class RegularizePunchPanel extends ConsumerStatefulWidget {
  const RegularizePunchPanel({super.key});

  @override
  ConsumerState<RegularizePunchPanel> createState() => _RegularizePunchPanelState();
}

class _RegularizePunchPanelState extends ConsumerState<RegularizePunchPanel> {
  String _selectedEmployee = 'Select Employee';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _proposedCheckInController = TextEditingController();
  final TextEditingController _proposedCheckOutController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    _proposedCheckInController.dispose();
    _proposedCheckOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isNarrow = screenWidth < 480;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 600,
            maxHeight: screenHeight * 0.65,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _buildHeader('Regularize Missed Punch'),
              ),
              const Divider(height: 16, color: AppColors.border),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Employee Name'),
                      _buildDropdown(['Select Employee', 'Rahul Dev', 'Michael Scott', 'Jim Halpert'], _selectedEmployee, (val) => setState(() => _selectedEmployee = val!)),
                      const SizedBox(height: 20),
                      _buildLabel('Timesheet Date'),
                      _buildDateField(_dateController, 'dd-mm-yyyy'),
                      const SizedBox(height: 20),
                      _buildLabel('Reason for Regularization'),
                      _buildTextField(_reasonController, 'Biometric mismatch/Travel delay'),
                      const SizedBox(height: 20),
                      
                      // Responsive row for proposed times
                      Wrap(
                        spacing: 16,
                        runSpacing: 20,
                        children: [
                          _buildWrapField(
                            width: isNarrow ? double.infinity : (screenWidth - 80) / 2,
                            label: 'Proposed Check-In',
                            child: _buildTimeField(_proposedCheckInController, '--:--'),
                          ),
                          _buildWrapField(
                            width: isNarrow ? double.infinity : (screenWidth - 80) / 2,
                            label: 'Proposed Check-Out',
                            child: _buildTimeField(_proposedCheckOutController, '--:--'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      _buildActionButton('Settle Regularization Request', const Color(0xFF2563EB)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
        ),
        IconButton(
          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.attendance),
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
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildWrapField({required double width, required String label, required Widget child}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String hint) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: true,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) controller.text = "${date.day}-${date.month}-${date.year}";
              },
            ),
          ),
          const Icon(LucideIcons.calendar, size: 14, color: AppColors.secondaryText),
        ],
      ),
    );
  }

  Widget _buildTimeField(TextEditingController controller, String hint) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: true,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
              ),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (time != null) controller.text = time.format(context);
              },
            ),
          ),
          const Icon(LucideIcons.clock, size: 14, color: AppColors.secondaryText),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.attendance),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}
