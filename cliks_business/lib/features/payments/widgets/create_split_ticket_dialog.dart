import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ParticipantEntry {
  final String name;
  final String email;
  final String role;
  final bool isCreator;

  ParticipantEntry({
    required this.name,
    required this.email,
    required this.role,
    this.isCreator = false,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'isCreator': isCreator,
        'isPending': !isCreator,
      };
}

class CreateSplitTicketDialog extends StatefulWidget {
  final String? currentUserName;
  final String? currentUserEmail;

  const CreateSplitTicketDialog({
    super.key,
    this.currentUserName,
    this.currentUserEmail,
  });

  @override
  State<CreateSplitTicketDialog> createState() => _CreateSplitTicketDialogState();
}

class _CreateSplitTicketDialogState extends State<CreateSplitTicketDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _participantNameController = TextEditingController();
  final _participantEmailController = TextEditingController();

  String _selectedCurrency = 'INR (₹)';
  final List<String> _currencies = [
    'INR (₹)',
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
  ];

  String _selectedRole = 'Edit Access';
  final List<Map<String, dynamic>> _roleOptions = [
    {'title': 'Edit Access', 'icon': LucideIcons.pencil, 'color': Color(0xFFB45309)},
    {'title': 'View Only', 'icon': LucideIcons.eye, 'color': Color(0xFF64748B)},
    {'title': 'Admin', 'icon': LucideIcons.crown, 'color': Color(0xFF047857)},
  ];

  late final List<ParticipantEntry> _participants;

  @override
  void initState() {
    super.initState();
    final name = (widget.currentUserName != null && widget.currentUserName!.isNotEmpty)
        ? widget.currentUserName!
        : 'Ravi K';
    final email = (widget.currentUserEmail != null && widget.currentUserEmail!.isNotEmpty)
        ? widget.currentUserEmail!
        : 'ravinew2004@bnxmail.com';

    _participants = [
      ParticipantEntry(
        name: name,
        email: email,
        role: 'Creator & Admin',
        isCreator: true,
      ),
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _participantNameController.dispose();
    _participantEmailController.dispose();
    super.dispose();
  }

  void _addParticipant() {
    final name = _participantNameController.text.trim();
    String email = _participantEmailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter participant name')),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter participant @bnxmail.com email')),
      );
      return;
    }

    if (!email.contains('@')) {
      email = '$email@bnxmail.com';
    } else if (!email.toLowerCase().endsWith('@bnxmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email address must strictly end with @bnxmail.com')),
      );
      return;
    }

    if (_participants.any((p) => p.email.toLowerCase() == email.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participant with this email is already added')),
      );
      return;
    }

    setState(() {
      _participants.add(
        ParticipantEntry(
          name: name,
          email: email,
          role: _selectedRole,
          isCreator: false,
        ),
      );
      _participantNameController.clear();
      _participantEmailController.clear();
      _selectedRole = 'Edit Access';
    });
  }

  void _removeParticipant(int index) {
    if (index >= 0 && index < _participants.length && !_participants[index].isCreator) {
      setState(() {
        _participants.removeAt(index);
      });
    }
  }

  IconData _getRoleIcon(String role) {
    if (role == 'Admin') return LucideIcons.crown;
    if (role == 'View Only') return LucideIcons.eye;
    return LucideIcons.pencil;
  }

  Color _getRoleColor(String role) {
    if (role == 'Admin') return const Color(0xFF047857);
    if (role == 'View Only') return const Color(0xFF64748B);
    return const Color(0xFFB45309);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Dialog(
      backgroundColor: Colors.white,
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 520,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Split Ticket',
                    style: TextStyle(
                      fontSize: 18.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFF64748B)),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(26, 4, 26, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: TICKET TITLE
                    _buildLabel('TICKET TITLE'),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'e.g. Goa Trip, Office lunch split',
                    ),
                    const SizedBox(height: 18),

                    // Section 2: GROUP CURRENCY & DESCRIPTION
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('GROUP CURRENCY'),
                              _buildCurrencyDropdown(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('DESCRIPTION'),
                              _buildTextField(
                                controller: _descriptionController,
                                hint: 'Optional details',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 3: PARTICIPANTS HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel('PARTICIPANTS (${_participants.length})'),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            'Strictly @bnxmail.com',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0E4D34),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Participant Name Input
                    _buildTextField(
                      controller: _participantNameController,
                      hint: 'Participant Name (e.g. John Doe)',
                    ),
                    const SizedBox(height: 10),

                    // Email + Permission Dropdown + Add Button Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _participantEmailController,
                            hint: 'member@bnxmail.com',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildRoleDropdownButton(),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            onPressed: _addParticipant,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0E4D34),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            child: const Text(
                              '+ Add',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0E4D34),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Participants List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _participants.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = _participants[index];
                        if (p.isCreator) {
                          return _buildCreatorParticipantCard(p);
                        }
                        return _buildAddedParticipantCard(p, index);
                      },
                    ),
                    const SizedBox(height: 26),

                    // Section 4: Create Ticket Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitCreateTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E4D34),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Ticket',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorParticipantCard(ParticipantEntry p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'You (${p.name}) (${p.email})',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF064E3B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF065F46),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.crown, size: 11, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Creator & Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddedParticipantCard(ParticipantEntry p, int index) {
    final roleColor = _getRoleColor(p.role);
    final roleIcon = _getRoleIcon(p.role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${p.name} (${p.email})',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(roleIcon, size: 11, color: roleColor),
                    const SizedBox(width: 4),
                    Text(
                      p.role,
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _removeParticipant(index),
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(
                    LucideIcons.x,
                    size: 14,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdownButton() {
    final currentOption = _roleOptions.firstWhere(
      (r) => r['title'] == _selectedRole,
      orElse: () => _roleOptions.first,
    );

    return PopupMenuButton<String>(
      tooltip: 'Select Permission',
      onSelected: (val) {
        setState(() => _selectedRole = val);
      },
      position: PopupMenuPosition.under,
      offset: const Offset(0, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      elevation: 4,
      itemBuilder: (context) {
        return _roleOptions.map((opt) {
          final isSelected = opt['title'] == _selectedRole;
          final color = opt['color'] as Color;
          final icon = opt['icon'] as IconData;

          return PopupMenuItem<String>(
            value: opt['title'] as String,
            height: 40,
            child: Row(
              children: [
                if (isSelected)
                  const Icon(LucideIcons.check, size: 14, color: Color(0xFF0F172A))
                else
                  const SizedBox(width: 14),
                const SizedBox(width: 8),
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 8),
                Text(
                  opt['title'] as String,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              currentOption['icon'] as IconData,
              size: 13,
              color: currentOption['color'] as Color,
            ),
            const SizedBox(width: 6),
            Text(
              _selectedRole,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCurrency,
          isExpanded: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
          items: _currencies.map((String c) {
            return DropdownMenuItem<String>(
              value: c,
              child: Text(
                c,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCurrency = val);
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF475569),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontSize: 13.5,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF0E4D34), width: 1.5),
        ),
      ),
    );
  }

  void _submitCreateTicket() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a ticket title')),
      );
      return;
    }

    String currencyCode = 'INR';
    String currencySymbol = '₹';
    if (_selectedCurrency.contains('USD')) {
      currencyCode = 'USD';
      currencySymbol = '\$';
    } else if (_selectedCurrency.contains('EUR')) {
      currencyCode = 'EUR';
      currencySymbol = '€';
    } else if (_selectedCurrency.contains('GBP')) {
      currencyCode = 'GBP';
      currencySymbol = '£';
    }

    final newTicket = {
      'id': 'ticket_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'currency': currencyCode,
      'currencySymbol': currencySymbol,
      'budget': 0.0,
      'category': 'General',
      'description': _descriptionController.text.trim().isEmpty
          ? 'No description'
          : _descriptionController.text.trim(),
      'participants': _participants.map((p) => p.name).toList(),
      'members': _participants.map((p) => p.toMap()).toList(),
      'expenses': <Map<String, dynamic>>[],
      'settlements': <Map<String, dynamic>>[],
      'createdAt': DateTime.now(),
    };

    Navigator.pop(context, newTicket);
  }
}
