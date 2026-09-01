import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/navigation_provider.dart';

class RegisterProductModal extends ConsumerStatefulWidget {
  const RegisterProductModal({super.key});

  @override
  ConsumerState<RegisterProductModal> createState() => _RegisterProductModalState();
}

class _RegisterProductModalState extends ConsumerState<RegisterProductModal> {
  bool isPhysicalProduct = true;
  String selectedCategory = 'Electronics';
  String selectedGstRate = '18% GST';
  String selectedTaxType = 'Tax Inclusive';
  String selectedPrimaryUnit = 'Pcs (Pieces)';

  @override
  Widget build(BuildContext context) {
    return _LargeModalWrapper(
      title: 'New Product Registration',
      subtitle: 'Code: PRO-8704',
      onClose: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.products),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle Physical/Service
          Row(
            children: [
              _buildToggleButton('Physical Product', isPhysicalProduct, () => setState(() => isPhysicalProduct = true)),
              const SizedBox(width: 8),
              _buildToggleButton('Service Offering', !isPhysicalProduct, () => setState(() => isPhysicalProduct = false)),
            ],
          ),
          const SizedBox(height: 24),

          // Basic Details
          _buildResponsiveThreeRow(
            context,
            [
              _buildInputField('ITEM NAME', 'e.g. MacBook Pro M3'),
              _buildInputField('SHORT DISPLAY NAME', 'MacBook'),
              _buildInputField('SKU CODE', 'MAC-M3-8'),
            ],
          ),
          const SizedBox(height: 16),

          _buildResponsiveFourRow(
            context,
            [
              _buildDropdownField('CATEGORY', selectedCategory, ['Electronics', 'Software', 'Hardware'], (val) => setState(() => selectedCategory = val!)),
              _buildInputField('BRAND', 'Apple'),
              _buildInputField('BARCODE NUMBER', 'Scan/Enter'),
              _buildInputField('HSN / SAC CODE', '8471'),
            ],
          ),
          const SizedBox(height: 16),

          // Pricing
          _buildResponsiveFourRow(
            context,
            [
              _buildInputField('PURCHASE COST (₹)', '0'),
              _buildInputField('RETAIL SELLING (₹)', '0'),
              _buildInputField('WHOLESALE PRICE (₹)', '0'),
              _buildInputField('DEALER PRICE (₹)', '0'),
            ],
          ),
          const SizedBox(height: 16),

          _buildResponsiveFourRow(
            context,
            [
              _buildInputField('MAX RETAIL PRICE (MRP)', '0'),
              _buildInputField('DISCOUNT %', '0'),
              _buildDropdownField('GST RATE (%)', selectedGstRate, ['18% GST', '12% GST', '5% GST', '0% GST'], (val) => setState(() => selectedGstRate = val!)),
              _buildDropdownField('TAX TYPE', selectedTaxType, ['Tax Inclusive', 'Tax Exclusive'], (val) => setState(() => selectedTaxType = val!)),
            ],
          ),
          const SizedBox(height: 24),

          // Inventory & Stock Controls Section
          _buildSectionHeader('INVENTORY & STOCK CONTROLS'),
          const SizedBox(height: 16),

          _buildResponsiveFourRow(
            context,
            [
              _buildInputField('Opening Qty', '0'),
              _buildInputField('Minimum Qty Alert', '5'),
              _buildInputField('Reorder Level', '8'),
              _buildDropdownField('Primary Unit', selectedPrimaryUnit, ['Pcs (Pieces)', 'Kgs', 'Mtrs'], (val) => setState(() => selectedPrimaryUnit = val!)),
            ],
          ),
          const SizedBox(height: 16),

          _buildResponsiveFourRow(
            context,
            [
              _buildInputField('Batch Identifier', 'B-8902'),
              _buildDateField('Expiry Date', 'dd-mm-yyyy'),
              _buildInputField('Warehouse', 'Main Godown'),
              _buildInputField('Rack Location', 'Rack 4'),
            ],
          ),
          const SizedBox(height: 32),

          // Register Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.products),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B61FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Register Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0F5B2E) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.secondaryText,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F5B2E),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hint, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
              const Icon(LucideIcons.calendar, size: 16, color: AppColors.secondaryText),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }
}

class AdjustStockModal extends ConsumerStatefulWidget {
  const AdjustStockModal({super.key});

  @override
  ConsumerState<AdjustStockModal> createState() => _AdjustStockModalState();
}

class _AdjustStockModalState extends ConsumerState<AdjustStockModal> {
  bool isAdding = true;
  String selectedProduct = 'Select Product';

  @override
  Widget build(BuildContext context) {
    return _SmallModalWrapper(
      title: 'Adjust Stock Counts',
      onClose: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.stock),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField('Select Product', selectedProduct, ['Select Product', 'iPhone 15', 'MacBook Pro'], (val) => setState(() => selectedProduct = val!)),
            const SizedBox(height: 20),
            _buildLabel('Adjustment Type'),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton('Add Stock (+)', isAdding, const Color(0xFF10B981), () => setState(() => isAdding = true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton('Reduce Stock (-)', !isAdding, const Color(0xFFF3F4F6), () => setState(() => isAdding = false), inactiveTextColor: AppColors.darkText),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInputField('Adjustment Qty', '10'),
            const SizedBox(height: 20),
            _buildInputField('Reason / Comment', 'Physical stock reconciliation audit'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.stock),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Finalize Stock Audit Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isActive, Color activeColor, VoidCallback onTap, {Color? inactiveTextColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : (inactiveTextColor ?? AppColors.secondaryText),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }
}

class WarehouseTransferModal extends ConsumerStatefulWidget {
  const WarehouseTransferModal({super.key});

  @override
  ConsumerState<WarehouseTransferModal> createState() => _WarehouseTransferModalState();
}

class _WarehouseTransferModalState extends ConsumerState<WarehouseTransferModal> {
  String selectedProduct = 'Select Product';
  String fromWarehouse = 'From Warehouse';
  String toWarehouse = 'To Warehouse';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return _SmallModalWrapper(
      title: 'Warehouse Stock Transfer',
      onClose: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.stock),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownField('Select Product', selectedProduct, ['Select Product', 'iPhone 15', 'MacBook Pro'], (val) => setState(() => selectedProduct = val!)),
            const SizedBox(height: 20),
            if (isMobile) ...[
              _buildDropdownField('From Warehouse', fromWarehouse, ['From Warehouse', 'Main Godown', 'Shop Front'], (val) => setState(() => fromWarehouse = val!)),
              const SizedBox(height: 20),
              _buildDropdownField('To Warehouse', toWarehouse, ['To Warehouse', 'Main Godown', 'Shop Front'], (val) => setState(() => toWarehouse = val!)),
            ] else
              Row(
                children: [
                  Expanded(child: _buildDropdownField('From Warehouse', fromWarehouse, ['From Warehouse', 'Main Godown', 'Shop Front'], (val) => setState(() => fromWarehouse = val!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdownField('To Warehouse', toWarehouse, ['To Warehouse', 'Main Godown', 'Shop Front'], (val) => setState(() => toWarehouse = val!))),
                ],
              ),
            const SizedBox(height: 20),
            _buildInputField('Quantity to Move', '15'),
            const SizedBox(height: 20),
            _buildInputField('Transfer Ref / ID', 'MIG-TRF-12'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.stock),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Initiate Transfer Release', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
      ),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterWarehouseModal extends ConsumerStatefulWidget {
  const RegisterWarehouseModal({super.key});

  @override
  ConsumerState<RegisterWarehouseModal> createState() => _RegisterWarehouseModalState();
}

class _RegisterWarehouseModalState extends ConsumerState<RegisterWarehouseModal> {
  String facilityType = 'Godown (Bulk Storage)';

  @override
  Widget build(BuildContext context) {
    return _SmallModalWrapper(
      title: 'Register New Warehouse Facility',
      onClose: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.warehouse),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildInputField('Warehouse Name', 'Delhi Godown')),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField('Warehouse Code', 'WH-DEL-04')),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownField('Facility Type', facilityType, ['Godown (Bulk Storage)', 'Distribution Center', 'Retail Outlet'], (val) => setState(() => facilityType = val!)),
            const SizedBox(height: 16),
            _buildInputField('Address', 'Plot No 40...'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInputField('City', '')),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField('State', '')),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField('Pincode', '')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInputField('Contact Manager Name', '')),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField('Contact Mobile No', '')),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.warehouse),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Register Facility Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 38,
          child: TextField(
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 38,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 11)))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }
}

class GoodsInwardReceiptModal extends ConsumerStatefulWidget {
  const GoodsInwardReceiptModal({super.key});

  @override
  ConsumerState<GoodsInwardReceiptModal> createState() => _GoodsInwardReceiptModalState();
}

class _GoodsInwardReceiptModalState extends ConsumerState<GoodsInwardReceiptModal> {
  String? selectedProduct;
  String? selectedWarehouse;

  @override
  Widget build(BuildContext context) {
    return _SmallModalWrapper(
      title: 'Goods Inward Receipt',
      onClose: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.warehouse),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField('Purchase Bill / Ref ID', 'BILL-90112'),
            const SizedBox(height: 16),
            _buildDropdownField('Product Name', selectedProduct, ['iPhone 15', 'MacBook Pro'], (val) => setState(() => selectedProduct = val!)),
            const SizedBox(height: 16),
            _buildInputField('Received Quantity', '0'),
            const SizedBox(height: 16),
            _buildDropdownField('Receiving Destination Warehouse', selectedWarehouse, ['Delhi Godown', 'Mumbai Hub'], (val) => setState(() => selectedWarehouse = val!)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.warehouse),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Log Good Inward Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }
}

class InterWarehouseTransferModal extends ConsumerStatefulWidget {
  const InterWarehouseTransferModal({super.key});

  @override
  ConsumerState<InterWarehouseTransferModal> createState() => _InterWarehouseTransferModalState();
}

class _InterWarehouseTransferModalState extends ConsumerState<InterWarehouseTransferModal> {
  String? fromWarehouse;
  String? toWarehouse;
  String? product;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    return _SmallModalWrapper(
      title: 'Inter-Warehouse Transfer',
      onClose: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.warehouse),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile) ...[
              _buildDropdownField('From Warehouse', fromWarehouse, ['Delhi Godown', 'Mumbai Hub'], (val) => setState(() => fromWarehouse = val!)),
              const SizedBox(height: 16),
              _buildDropdownField('To Warehouse', toWarehouse, ['Delhi Godown', 'Mumbai Hub'], (val) => setState(() => toWarehouse = val!)),
            ] else
              Row(
                children: [
                  Expanded(child: _buildDropdownField('From Warehouse', fromWarehouse, ['Delhi Godown', 'Mumbai Hub'], (val) => setState(() => fromWarehouse = val!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDropdownField('To Warehouse', toWarehouse, ['Delhi Godown', 'Mumbai Hub'], (val) => setState(() => toWarehouse = val!))),
                ],
              ),
            const SizedBox(height: 16),
            _buildDropdownField('Product Description', product, ['iPhone 15', 'MacBook Pro'], (val) => setState(() => product = val!)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInputField('Transfer Qty', '0')),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField('Logistics Carrier', 'FedEx')),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => ref.read(navigationProvider.notifier).setRoute(AppRoute.warehouse),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5B2E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Initiate Inter-Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText)),
    );
  }

  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallModalWrapper extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget child;

  const _SmallModalWrapper({
    required this.title,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 420,
            maxHeight: screenHeight * 0.65,
          ),
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(24),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(LucideIcons.x, size: 18, color: Colors.black54),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _LargeModalWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onClose;
  final Widget child;

  const _LargeModalWrapper({
    required this.title,
    required this.subtitle,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 900;

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 800,
            maxHeight: screenHeight * 0.65,
          ),
          margin: EdgeInsets.zero,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(LucideIcons.x, size: 18, color: Colors.black54),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              
              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildResponsiveThreeRow(BuildContext context, List<Widget> children) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth < 600) {
    return Column(
      children: [
        children[0],
        const SizedBox(height: 16),
        children[1],
        const SizedBox(height: 16),
        children[2],
      ],
    );
  }
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: children[0]),
      const SizedBox(width: 12),
      Expanded(child: children[1]),
      const SizedBox(width: 12),
      Expanded(child: children[2]),
    ],
  );
}

Widget _buildResponsiveFourRow(BuildContext context, List<Widget> children) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth < 750) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 12),
            Expanded(child: children[1]),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: children[2]),
            const SizedBox(width: 12),
            Expanded(child: children[3]),
          ],
        ),
      ],
    );
  }
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: children[0]),
      const SizedBox(width: 12),
      Expanded(child: children[1]),
      const SizedBox(width: 12),
      Expanded(child: children[2]),
      const SizedBox(width: 12),
      Expanded(child: children[3]),
    ],
  );
}
