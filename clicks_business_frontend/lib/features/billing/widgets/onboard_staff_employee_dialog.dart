import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class OnboardStaffEmployeeDialog extends StatefulWidget {
  const OnboardStaffEmployeeDialog({super.key});

  @override
  State<OnboardStaffEmployeeDialog> createState() => _OnboardStaffEmployeeDialogState();
}

class _OnboardStaffEmployeeDialogState extends State<OnboardStaffEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Form State
  String _gender = 'Male';
  String _department = 'Operations';
  String _employmentType = 'Full-time';
  String _assignedShift = 'Morning Shift (6 AM - 2 PM)';
  DateTime _dob = DateTime.now();
  DateTime _joiningDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isDob) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDob ? _dob : _joiningDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          _dob = picked;
        } else {
          _joiningDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Dialog(
      backgroundColor: Colors.white,
      alignment: Alignment.bottomCenter,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      insetPadding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 1000,
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Align(
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
            ),
            // Header
            _buildHeader(context),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            
            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Section 1 & 2 in a Row (Desktop) or Column (Mobile)
                      if (!isMobile)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildPersonalDetailsSection(isMobile)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildJobDesignationSection(isMobile)),
                          ],
                        )
                      else ...[
                        _buildPersonalDetailsSection(isMobile),
                        const SizedBox(height: 24),
                        _buildJobDesignationSection(isMobile),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Section 3: Payroll & Financial Structure
                      _buildPayrollSection(isMobile),
                      
                      const SizedBox(height: 32),
                      
                      // Section 4: Address & Emergency Details
                      _buildAddressEmergencySection(isMobile),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            _buildFooter(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF0F5B2E),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.userPlus, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Onboard Staff Employee',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x, size: 18, color: Colors.black54),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection(bool isMobile) {
    return _buildContainer(
      title: 'Personal Details',
      icon: LucideIcons.user,
      child: Column(
        children: [
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'First Name', initialValue: 'Arun')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'Last Name', initialValue: 'Kumar')),
              ],
            )
          else ...[
            _buildTextField(label: 'First Name', initialValue: 'Arun'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Last Name', initialValue: 'Kumar'),
          ],
          const SizedBox(height: 16),
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildDateField(label: 'Date of Birth', date: _dob, onTap: () => _selectDate(context, true))),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdownField(
                  label: 'Gender',
                  value: _gender,
                  items: ['Male', 'Female', 'Other'],
                  onChanged: (val) => setState(() => _gender = val!),
                )),
              ],
            )
          else ...[
            _buildDateField(label: 'Date of Birth', date: _dob, onTap: () => _selectDate(context, true)),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Gender',
              value: _gender,
              items: ['Male', 'Female', 'Other'],
              onChanged: (val) => setState(() => _gender = val!),
            ),
          ],
          const SizedBox(height: 16),
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Blood Group', initialValue: 'O+')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'Phone', initialValue: '+91 98765 43210')),
              ],
            )
          else ...[
            _buildTextField(label: 'Blood Group', initialValue: 'O+'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Phone', initialValue: '+91 98765 43210'),
          ],
          const SizedBox(height: 16),
          _buildTextField(label: 'Corporate Email', initialValue: 'arun.kumar@clikbusiness.com'),
        ],
      ),
    );
  }

  Widget _buildJobDesignationSection(bool isMobile) {
    return _buildContainer(
      title: 'Job & Designation',
      icon: LucideIcons.briefcase,
      child: Column(
        children: [
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildDropdownField(
                  label: 'Department',
                  value: _department,
                  items: ['Operations', 'Sales', 'Marketing', 'IT', 'HR'],
                  onChanged: (val) => setState(() => _department = val!),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'Designation Title', initialValue: 'Sales Executive (Default)')),
              ],
            )
          else ...[
            _buildDropdownField(
              label: 'Department',
              value: _department,
              items: ['Operations', 'Sales', 'Marketing', 'IT', 'HR'],
              onChanged: (val) => setState(() => _department = val!),
            ),
            const SizedBox(height: 16),
            _buildTextField(label: 'Designation Title', initialValue: 'Sales Executive (Default)'),
          ],
          const SizedBox(height: 16),
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildDropdownField(
                  label: 'Employment Type',
                  value: _employmentType,
                  items: ['Full-time', 'Part-time', 'Contract', 'Intern'],
                  onChanged: (val) => setState(() => _employmentType = val!),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildDateField(label: 'Joining Date', date: _joiningDate, onTap: () => _selectDate(context, false))),
              ],
            )
          else ...[
            _buildDropdownField(
              label: 'Employment Type',
              value: _employmentType,
              items: ['Full-time', 'Part-time', 'Contract', 'Intern'],
              onChanged: (val) => setState(() => _employmentType = val!),
            ),
            const SizedBox(height: 16),
            _buildDateField(label: 'Joining Date', date: _joiningDate, onTap: () => _selectDate(context, false)),
          ],
          const SizedBox(height: 16),
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Reporting Manager', initialValue: 'Ankit Sharma (Sales Lead)')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'Leaves Bal', initialValue: '14')),
              ],
            )
          else ...[
            _buildTextField(label: 'Reporting Manager', initialValue: 'Ankit Sharma (Sales Lead)'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Leaves Bal', initialValue: '14'),
          ],
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Assigned Shift',
            value: _assignedShift,
            items: ['Morning Shift (6 AM - 2 PM)', 'Day Shift (9 AM - 6 PM)', 'Night Shift (10 PM - 6 AM)'],
            onChanged: (val) => setState(() => _assignedShift = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollSection(bool isMobile) {
    return _buildContainer(
      title: 'Payroll & Financial Structure',
      icon: LucideIcons.creditCard,
      child: Column(
        children: [
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Basic Monthly Salary (INR)', initialValue: '35000 (Default)')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'PAN Number', initialValue: 'ABCDE1234F (Default)')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'PF Number', initialValue: 'MH/BAN/0011223/001 (Default)')),
              ],
            )
          else ...[
            _buildTextField(label: 'Basic Monthly Salary (INR)', initialValue: '35000 (Default)'),
            const SizedBox(height: 16),
            _buildTextField(label: 'PAN Number', initialValue: 'ABCDE1234F (Default)'),
            const SizedBox(height: 16),
            _buildTextField(label: 'PF Number', initialValue: 'MH/BAN/0011223/001 (Default)'),
          ],
          const SizedBox(height: 16),
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Bank Name', initialValue: 'HDFC Bank (Default)')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'Bank Account Number', initialValue: '50100223344551 (Default)')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'IFSC Code', initialValue: 'HDFC0000124 (Default)')),
              ],
            )
          else ...[
            _buildTextField(label: 'Bank Name', initialValue: 'HDFC Bank (Default)'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Bank Account Number', initialValue: '50100223344551 (Default)'),
            const SizedBox(height: 16),
            _buildTextField(label: 'IFSC Code', initialValue: 'HDFC0000124 (Default)'),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressEmergencySection(bool isMobile) {
    return _buildContainer(
      title: 'Address & Emergency Details',
      icon: LucideIcons.mapPin,
      child: Column(
        children: [
          _buildTextField(label: 'Residential Address Line 1', initialValue: 'Plot No. 12, Anna Nagar (Default)'),
          const SizedBox(height: 16),
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'City', initialValue: 'Chennai')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'State', initialValue: 'Tamil Nadu')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'Pincode', initialValue: '600040')),
              ],
            )
          else ...[
            _buildTextField(label: 'City', initialValue: 'Chennai'),
            const SizedBox(height: 16),
            _buildTextField(label: 'State', initialValue: 'Tamil Nadu'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Pincode', initialValue: '600040'),
          ],
          const SizedBox(height: 16),
          if (!isMobile)
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Emergency Contact Name', initialValue: 'Vijay Kumar (Father) (Default)')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(label: 'Emergency Phone', initialValue: '+91 98765 99911 (Default)')),
              ],
            )
          else ...[
            _buildTextField(label: 'Emergency Contact Name', initialValue: 'Vijay Kumar (Father) (Default)'),
            const SizedBox(height: 16),
            _buildTextField(label: 'Emergency Phone', initialValue: '+91 98765 99911 (Default)'),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5B2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Onboard Staff Employee', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: AppColors.darkText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              foregroundColor: AppColors.darkText,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5B2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Onboard Staff Employee', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.secondaryText),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, String? initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String value, required List<String> items, required void Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: AppColors.darkText),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField({required String label, required DateTime date, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${date.day}-${date.month}-${date.year}", style: const TextStyle(fontSize: 13)),
                const Icon(LucideIcons.calendar, size: 14, color: AppColors.secondaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
