import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class VerifyIcaiDialog extends StatefulWidget {
  final void Function(String name, String firm, String regNo, String designation, String chapter)? onVerified;
  final String? initialName;
  final String? initialFirm;
  final String? initialRegNo;
  final String? initialDesignation;
  final String? initialChapter;

  const VerifyIcaiDialog({
    super.key,
    this.onVerified,
    this.initialName,
    this.initialFirm,
    this.initialRegNo,
    this.initialDesignation,
    this.initialChapter,
  });

  @override
  State<VerifyIcaiDialog> createState() => _VerifyIcaiDialogState();
}

class _VerifyIcaiDialogState extends State<VerifyIcaiDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _firmController;
  late final TextEditingController _regNoController;
  final _emailController = TextEditingController(text: 'ravinew2004@bnxmail.com');
  final _addressController = TextEditingController();

  String _selectedCop = 'Active';
  String _selectedDesignation = 'Associate Member (ACA)';
  String _selectedChapter = 'Southern India Regional Council (SIRC)';

  final List<String> _copOptions = [
    'Active',
    'Inactive',
    'Applied',
    'Under Renewal',
  ];

  final List<String> _designationOptions = [
    'Associate Member (ACA)',
    'Fellow Member (FCA)',
  ];

  final List<String> _chapterOptions = [
    'Southern India Regional Council (SIRC)',
    'Western India Regional Council (WIRC)',
    'Northern India Regional Council (NIRC)',
    'Eastern India Regional Council (EIRC)',
    'Central India Regional Council (CIRC)',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _firmController = TextEditingController(text: widget.initialFirm ?? '');
    _regNoController = TextEditingController(text: widget.initialRegNo ?? '');
    if (widget.initialDesignation != null && _designationOptions.contains(widget.initialDesignation)) {
      _selectedDesignation = widget.initialDesignation!;
    }
    if (widget.initialChapter != null && _chapterOptions.contains(widget.initialChapter)) {
      _selectedChapter = widget.initialChapter!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firmController.dispose();
    _regNoController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'CA Rajesh Sharma';
    final firm = _firmController.text.trim().isNotEmpty
        ? _firmController.text.trim()
        : 'Sharma & Associates LLP';
    final regNo = _regNoController.text.trim().isNotEmpty
        ? _regNoController.text.trim()
        : '508219';

    Navigator.of(context).pop();
    widget.onVerified?.call(name, firm, regNo, _selectedDesignation, _selectedChapter);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.shieldCheck, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'ICAI credentials submitted successfully for institutional verification.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF056B43),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            fontFamily: 'Inter',
          ),
          children: isRequired
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    bool isMonospace = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF056B43), width: 1.5),
      ),
    );
  }

  Widget _buildDropdownContainer({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF056B43)),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF056B43),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 660,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── GREEN HEADER BAR ───
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                decoration: const BoxDecoration(
                  color: Color(0xFF056B43),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF045434),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.shieldCheck,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verify ICAI Member Credentials',
                            style: TextStyle(
                              fontSize: 17.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Submit your official membership records for institutional CA accreditation.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFD1FAE5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.x,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── FORM CONTENT ───
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROW 1: CA Full Name & Firm / Practice Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('CA Full Name', isRequired: true),
                              TextField(
                                controller: _nameController,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                                decoration: _buildInputDecoration(hintText: 'e.g. CA Rajesh Sharma'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Firm / Practice Name', isRequired: true),
                              TextField(
                                controller: _firmController,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
                                decoration: _buildInputDecoration(hintText: 'e.g. Sharma & Associates LLP'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ROW 2: ICAI Membership / Reg No. & Professional Email
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('ICAI Membership / Reg No.', isRequired: true),
                              TextField(
                                controller: _regNoController,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF111827),
                                  letterSpacing: 0.5,
                                  fontFamily: 'monospace',
                                ),
                                decoration: _buildInputDecoration(
                                  hintText: 'e.g. 508219',
                                  isMonospace: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Professional Email', isRequired: true),
                              TextField(
                                controller: _emailController,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF056B43),
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _buildInputDecoration(hintText: 'ravinew2004@bnxmail.com'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ROW 3: Certificate of Practice (COP) & Member Designation
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Certificate of Practice (COP)'),
                              _buildDropdownContainer(
                                value: _selectedCop,
                                items: _copOptions,
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCop = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Member Designation'),
                              _buildDropdownContainer(
                                value: _selectedDesignation,
                                items: _designationOptions,
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedDesignation = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ROW 4: ICAI Regional Council Chapter
                    _buildFieldLabel('ICAI Regional Council Chapter'),
                    _buildDropdownContainer(
                      value: _selectedChapter,
                      items: _chapterOptions,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedChapter = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // ROW 5: Professional Office Address
                    _buildFieldLabel('Professional Office Address'),
                    Stack(
                      children: [
                        TextField(
                          controller: _addressController,
                          minLines: 3,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF111827), height: 1.4),
                          decoration: InputDecoration(
                            hintText: 'Enter registered practice address, city, state, and pincode...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: const EdgeInsets.all(14),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 1.1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF056B43), width: 1.5),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: CustomPaint(
                            size: const Size(10, 10),
                            painter: _ResizeGripPainter(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── DIVIDER ───
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

              // ─── BOTTOM ACTION BUTTONS ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _handleSubmit,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFF056B43),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF056B43).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Submit for ICAI Verification',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResizeGripPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width, size.height - 3), Offset(size.width - 3, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - 7), Offset(size.width - 7, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
