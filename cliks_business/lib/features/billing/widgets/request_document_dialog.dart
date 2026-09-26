import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RequestDocumentDialog extends StatefulWidget {
  const RequestDocumentDialog({super.key});

  @override
  State<RequestDocumentDialog> createState() => _RequestDocumentDialogState();
}

class _RequestDocumentDialogState extends State<RequestDocumentDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _customCategoryController = TextEditingController();

  String? _selectedClient;
  String _selectedCategory = 'Form 16 PDF';
  String _selectedPriority = 'Medium';

  final List<String> _clients = [
    'Reliance Industries Ltd (Client-01)',
    'Tata Consultancy Services (Client-02)',
    'Infosys Ltd (Client-03)',
    'Balaji Heavy Roadways (Client-04)',
    'Sharma Logistics (Client-05)',
    'Apex Retailers LLP (Client-06)',
  ];

  final List<String> _categories = [
    'Form 16 PDF',
    'GSTR-1 / 3B Return',
    'Bank Statement',
    'Balance Sheet & P&L',
    'TDS / 26AS Tax Credit Statement',
    '+ Custom Document Category',
  ];

  final List<String> _priorities = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _handleIssueRequest() {
    final title = _titleController.text.trim();
    final clientName = _selectedClient ?? 'Taxpayer';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title.isNotEmpty
              ? 'Document request "$title" issued to $clientName successfully.'
              : 'Document request issued to $clientName successfully.',
        ),
        backgroundColor: const Color(0xFF166534),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isCustomCategory = _selectedCategory == '+ Custom Document Category';

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
                '🤝 Request Document from Taxpayer',
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

              // 2. REQUEST TITLE
              _buildFieldLabel('REQUEST TITLE'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Form 16 Q4, Q1 GST Ledger...',
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

              // 3. DESCRIPTION / INSTRUCTIONS
              _buildFieldLabel('DESCRIPTION / INSTRUCTIONS'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Please upload the employer issued Form 16...',
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(14),
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

              // 4. DOCUMENT CATEGORY
              _buildFieldLabel('DOCUMENT CATEGORY'),
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
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF4B5563)),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: cat.startsWith('+') ? const Color(0xFF166534) : const Color(0xFF111827),
                            fontWeight: cat.startsWith('+') ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      }
                    },
                  ),
                ),
              ),

              // DYNAMIC CUSTOM CATEGORY INPUT (When + Custom Document Category is selected)
              if (isCustomCategory) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customCategoryController,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter custom category (e.g. Sales Ledger)...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF0FDF4),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF166534), width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF166534), width: 1.8),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // 5. PRIORITY
              _buildFieldLabel('PRIORITY'),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: Container(
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
                    onPressed: _handleIssueRequest,
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
                      'Issue Request',
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
