import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AssignTaskDialog extends StatefulWidget {
  const AssignTaskDialog({super.key});

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _dueDateController = TextEditingController();

  String? _selectedClient;
  String _selectedPriority = 'Medium';
  bool _requireUpload = false;

  final List<String> _clients = [
    'Reliance Industries Ltd (Client-01)',
    'Tata Consultancy Services (Client-02)',
    'Infosys Ltd (Client-03)',
    'Balaji Heavy Roadways (Client-04)',
    'Sharma Logistics (Client-05)',
    'Apex Retailers LLP (Client-06)',
  ];

  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _titleController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF166534),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {
        _dueDateController.text = formatted;
      });
    }
  }

  void _handleAssignTask() {
    final title = _titleController.text.trim();
    final clientName = _selectedClient ?? 'Client';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title.isNotEmpty
              ? 'Operation task "$title" assigned to $clientName successfully.'
              : 'Operation task assigned to $clientName successfully.',
        ),
        backgroundColor: const Color(0xFF166534),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                '✅ Assign Practice Operation Task',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 22),

              // 1. SELECT CLIENT
              _buildFieldLabel('SELECT CLIENT'),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedClient,
                    isExpanded: true,
                    hint: const SizedBox.shrink(),
                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF4B5563)),
                    items: _clients.map((client) {
                      return DropdownMenuItem<String>(
                        value: client,
                        child: Text(
                          client,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedClient = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. BUSINESS OWNER EMAIL (For sync & notification) *
              _buildFieldLabel('BUSINESS OWNER EMAIL (For sync & notification) *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. owner@business.com',
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. TASK DESCRIPTION TITLE
              _buildFieldLabel('TASK DESCRIPTION TITLE'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Draft return, verify investment deductions...',
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF166534), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 4. PRIORITY & DUE DATE (Side by Side)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRIORITY
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('PRIORITY'),
                        const SizedBox(height: 8),
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPriority,
                              isExpanded: true,
                              icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF4B5563)),
                              items: _priorities.map((priority) {
                                return DropdownMenuItem<String>(
                                  value: priority,
                                  child: Text(
                                    priority,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF111827),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedPriority = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // DUE DATE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('DUE DATE'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFD1D5DB), width: 1.2),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _dueDateController.text.isEmpty ? 'dd/mm/yyyy' : _dueDateController.text,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: _dueDateController.text.isEmpty
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF111827),
                                      fontWeight: _dueDateController.text.isEmpty
                                          ? FontWeight.w400
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  LucideIcons.calendar,
                                  size: 16,
                                  color: Color(0xFF111827),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 5. Checkbox: Require document upload from client
              InkWell(
                onTap: () {
                  setState(() {
                    _requireUpload = !_requireUpload;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _requireUpload,
                          activeColor: const Color(0xFF166534),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: const BorderSide(color: Color(0xFF9CA3AF), width: 1.5),
                          onChanged: (val) {
                            setState(() {
                              _requireUpload = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Require document upload from client',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF374151),
                      side: const BorderSide(color: Color(0xFFD1D5DB), width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: _handleAssignTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Assign Task',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4B5563),
        letterSpacing: 0.5,
      ),
    );
  }
}
