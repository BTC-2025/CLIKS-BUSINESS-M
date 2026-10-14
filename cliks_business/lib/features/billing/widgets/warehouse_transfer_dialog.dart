import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class WarehouseTransferDialog extends StatefulWidget {
  final void Function(String product, String fromWh, String toWh, String qty, String refId)? onTransferInitiated;

  const WarehouseTransferDialog({
    super.key,
    this.onTransferInitiated,
  });

  @override
  State<WarehouseTransferDialog> createState() => _WarehouseTransferDialogState();
}

class _WarehouseTransferDialogState extends State<WarehouseTransferDialog> {
  final _qtyController = TextEditingController(text: '15');
  final _refController = TextEditingController(text: 'MIG-TRF-12');

  String _selectedProduct = '-- Select Product --';
  String _fromWarehouse = 'Damaged products';
  String _toWarehouse = '787';

  final List<String> _products = [
    '-- Select Product --',
    'a new digit product',
    'apple',
    'carrot',
    'Tshirt',
    's1 book',
    'laptop',
  ];

  final List<String> _fromWarehouses = [
    'Damaged products',
    'Main Godown (Rack A-1)',
    'Chennai godown',
    'Tiruvallur godown',
  ];

  final List<String> _toWarehouses = [
    '787',
    'Damaged products godown',
    'Main Godown (Rack A-1)',
    'Chennai godown',
    'Tiruvallur godown',
  ];

  @override
  void dispose() {
    _qtyController.dispose();
    _refController.dispose();
    super.dispose();
  }

  void _submit() {
    final qty = _qtyController.text.trim();
    final refId = _refController.text.trim();

    if (_selectedProduct == '-- Select Product --') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product to transfer.'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (qty.isEmpty || int.tryParse(qty) == null || int.parse(qty) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid transfer quantity.'),
          backgroundColor: Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (widget.onTransferInitiated != null) {
      widget.onTransferInitiated!(
        _selectedProduct,
        _fromWarehouse,
        _toWarehouse,
        '$qty pcs',
        refId.isEmpty ? 'TRF-${DateTime.now().millisecondsSinceEpoch % 1000}' : refId,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 550;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: isMobile ? double.infinity : 460,
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Warehouse Stock Transfer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Select Product
                _buildFieldLabel('Select Product'),
                _buildDropdown(
                  value: _selectedProduct,
                  items: _products,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedProduct = val);
                  },
                ),
                const SizedBox(height: 18),

                // From Warehouse & To Warehouse Row
                if (isMobile) ...[
                  _buildFieldLabel('From Warehouse'),
                  _buildDropdown(
                    value: _fromWarehouse,
                    items: _fromWarehouses,
                    onChanged: (val) {
                      if (val != null) setState(() => _fromWarehouse = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('To Warehouse'),
                  _buildDropdown(
                    value: _toWarehouse,
                    items: _toWarehouses,
                    onChanged: (val) {
                      if (val != null) setState(() => _toWarehouse = val);
                    },
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('From Warehouse'),
                            _buildDropdown(
                              value: _fromWarehouse,
                              items: _fromWarehouses,
                              onChanged: (val) {
                                if (val != null) setState(() => _fromWarehouse = val);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('To Warehouse'),
                            _buildDropdown(
                              value: _toWarehouse,
                              items: _toWarehouses,
                              onChanged: (val) {
                                if (val != null) setState(() => _toWarehouse = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 18),

                // Quantity to Move
                _buildFieldLabel('Quantity to Move'),
                _buildTextField(
                  controller: _qtyController,
                  hintText: '15',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 18),

                // Transfer Ref / ID
                _buildFieldLabel('Transfer Ref / ID'),
                _buildTextField(
                  controller: _refController,
                  hintText: 'MIG-TRF-12',
                ),
                const SizedBox(height: 26),

                // Action Button: Initiate Transfer Release
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Initiate Transfer Release',
                      style: TextStyle(
                        fontSize: 14,
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
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Ensure value is present in items
    final safeValue = items.contains(value) ? value : items.first;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          isExpanded: true,
          icon: const Icon(
            LucideIcons.chevronDown,
            size: 16,
            color: Color(0xFF64748B),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: item.startsWith('--')
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
