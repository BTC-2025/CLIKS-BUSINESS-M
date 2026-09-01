import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/navigation_provider.dart';
import '../../../core/theme/app_colors.dart';

class EmployeeLoanPanel extends ConsumerStatefulWidget {
  const EmployeeLoanPanel({super.key});

  @override
  ConsumerState<EmployeeLoanPanel> createState() => _EmployeeLoanPanelState();
}

class _EmployeeLoanPanelState extends ConsumerState<EmployeeLoanPanel> {
  String _selectedEmployee = '-- Select Employee --';
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _emiController = TextEditingController();
  final TextEditingController _advanceController = TextEditingController();

  @override
  void dispose() {
    _loanAmountController.dispose();
    _emiController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isNarrow = screenWidth < 400;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 500,
            maxHeight: screenHeight * 0.8,
          ),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                child: _buildHeader('Grant Employee Loan'),
              ),
              const Divider(height: 16, color: AppColors.border),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Employee Name'),
                      _buildDropdown(
                        ['-- Select Employee --', 'Rahul Dev', 'Michael Scott', 'Jim Halpert'],
                        _selectedEmployee,
                        (val) => setState(() => _selectedEmployee = val!),
                      ),
                      const SizedBox(height: 20),
                      
                      // Responsive fields side-by-side on desktop, stacked on narrow screens
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Loan Amount (₹)'),
                                _buildTextField(_loanAmountController, '0', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Monthly EMI'),
                                _buildTextField(_emiController, '0', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      _buildLabel('Immediate Salary Advance (₹)'),
                      _buildTextField(_advanceController, '0', keyboardType: TextInputType.number),
                      const SizedBox(height: 32),
                      _buildActionButton('Settle Granted Loan Allocation', const Color(0xFF7C3AED)),
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
              color: Color(0xFF004D40), // Dark green color matching standard app headers
            ),
          ),
        ),
        IconButton(
          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.payroll),
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

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      height: 44,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.payroll),
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

class ProcessPayrollPanel extends ConsumerStatefulWidget {
  const ProcessPayrollPanel({super.key});

  @override
  ConsumerState<ProcessPayrollPanel> createState() => _ProcessPayrollPanelState();
}

class _ProcessPayrollPanelState extends ConsumerState<ProcessPayrollPanel> {
  String _selectedEmployee = '-- Select Staff Member --';
  bool _deductPF = true;
  final TextEditingController _baseSalaryController = TextEditingController();
  final TextEditingController _hraController = TextEditingController();
  final TextEditingController _specialAllowanceController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _esiController = TextEditingController(text: '325');
  final TextEditingController _tdsController = TextEditingController();

  @override
  void dispose() {
    _baseSalaryController.dispose();
    _hraController.dispose();
    _specialAllowanceController.dispose();
    _bonusController.dispose();
    _esiController.dispose();
    _tdsController.dispose();
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
        alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 550,
            maxHeight: screenHeight * 0.85,
          ),
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                child: _buildHeader('Process Monthly Payroll'),
              ),
              const Divider(height: 16, color: AppColors.border),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Select Employee'),
                      _buildDropdown(
                        ['-- Select Staff Member --', 'Rahul Dev', 'Michael Scott', 'Jim Halpert'],
                        _selectedEmployee,
                        (val) => setState(() => _selectedEmployee = val!),
                      ),
                      const SizedBox(height: 20),

                      // First Row: Basic & HRA
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Basic Base Salary (₹)'),
                                _buildTextField(_baseSalaryController, '0', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('HRA Allowance (₹)'),
                                _buildTextField(_hraController, '0', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Second Row: Special & Bonus
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Special Allowance'),
                                _buildTextField(_specialAllowanceController, '0', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Bonus / Incentives'),
                                _buildTextField(_bonusController, '0', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Third Row: PF, ESI, TDS
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PF Checkbox column
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _deductPF,
                                        onChanged: (val) => setState(() => _deductPF = val!),
                                        activeColor: const Color(0xFF7C3AED),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text('Deduct 12% PF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 32, top: 4),
                                  child: Text('Est: ₹0', style: TextStyle(fontSize: 10, color: AppColors.secondaryText)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // ESI Field
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('ESI Deduction'),
                                _buildTextField(_esiController, '325', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // TDS Field
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Estimated TDS'),
                                _buildTextField(_tdsController, '0', keyboardType: TextInputType.number),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      _buildActionButton('Settle Monthly Take-Home Salary', const Color(0xFF7C3AED)),
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
              color: Color(0xFF004D40), // Dark green color
            ),
          ),
        ),
        IconButton(
          onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.payroll),
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

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Container(
      height: 44,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.payroll),
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
