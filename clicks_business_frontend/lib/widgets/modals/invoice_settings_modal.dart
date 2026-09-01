import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../features/billing/providers/invoice_settings_provider.dart';
import '../app_ui_kit.dart';

class InvoiceSettingsModal extends ConsumerStatefulWidget {
  const InvoiceSettingsModal({super.key});

  @override
  ConsumerState<InvoiceSettingsModal> createState() => _InvoiceSettingsModalState();
}

class _InvoiceSettingsModalState extends ConsumerState<InvoiceSettingsModal> {
  late List<String> invoiceTypes;
  late List<String> invoiceStatuses;
  late List<String> paymentModes;
  late List<String> termsList;
  late List<String> unitsList;
  late List<String> gstRates;
  late List<String> discountTypes;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(invoiceSettingsProvider);
    invoiceTypes = List.from(settings.invoiceTypes);
    invoiceStatuses = List.from(settings.invoiceStatuses);
    paymentModes = List.from(settings.paymentModes);
    termsList = List.from(settings.termsList);
    unitsList = List.from(settings.unitsList);
    gstRates = List.from(settings.gstRates);
    discountTypes = List.from(settings.discountTypes);
  }

  void _showAddItemDialog(String categoryTitle, List<String> list) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add to $categoryTitle', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new value',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                setState(() {
                  list.add(val);
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9E125D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(String categoryTitle, List<String> list, int index) {
    final controller = TextEditingController(text: list[index]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $categoryTitle Item', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter value',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                setState(() {
                  list[index] = val;
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9E125D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeItem(List<String> list, int index) {
    if (list.length > 1) {
      setState(() {
        list.removeAt(index);
      });
    } else {
      AppSnackbar.show(context, "Category must have at least one option", type: SnackType.info);
    }
  }

  void _saveSettings() {
    final newState = InvoiceSettingsState(
      invoiceTypes: invoiceTypes,
      invoiceStatuses: invoiceStatuses,
      paymentModes: paymentModes,
      termsList: termsList,
      unitsList: unitsList,
      gstRates: gstRates,
      discountTypes: discountTypes,
    );

    ref.read(invoiceSettingsProvider.notifier).updateSettings(newState);
    AppSnackbar.show(context, "Invoice settings updated successfully!", type: SnackType.success);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.black45,
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 820,
            maxHeight: screenHeight * 0.90,
          ),
          margin: EdgeInsets.all(isMobile ? 12 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row matching screenshot
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Invoice Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, size: 16, color: AppColors.secondaryText),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(6),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // Scrollable Content area with 7 Cards
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (isMobile) ...[
                        _buildCategoryCard('INVOICE TYPE', invoiceTypes),
                        const SizedBox(height: 16),
                        _buildCategoryCard('INVOICE STATUS', invoiceStatuses),
                        const SizedBox(height: 16),
                        _buildCategoryCard('PAYMENT MODE', paymentModes),
                        const SizedBox(height: 16),
                        _buildCategoryCard('TERMS', termsList),
                        const SizedBox(height: 16),
                        _buildCategoryCard('UNITS', unitsList),
                        const SizedBox(height: 16),
                        _buildCategoryCard('GST %', gstRates),
                        const SizedBox(height: 16),
                        _buildCategoryCard('DISCOUNT TYPES', discountTypes),
                      ] else ...[
                        // Row 1: INVOICE TYPE, INVOICE STATUS, PAYMENT MODE
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCategoryCard('INVOICE TYPE', invoiceTypes)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildCategoryCard('INVOICE STATUS', invoiceStatuses)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildCategoryCard('PAYMENT MODE', paymentModes)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 2: TERMS, UNITS, GST %
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCategoryCard('TERMS', termsList)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildCategoryCard('UNITS', unitsList)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildCategoryCard('GST %', gstRates)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 3: DISCOUNT TYPES
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: (820 - 40 - 32) / 3, // Match width of 1 column
                              child: _buildCategoryCard('DISCOUNT TYPES', discountTypes),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // Bottom Bar matching screenshot (Cancel & Save Changes)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkText,
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9E125D), // Magenta / Maroon matching screenshot
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildCategoryCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Add button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () => _showAddItemDialog(title, items),
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '+ Add',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9E125D),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List of items
          Column(
            children: List.generate(items.length, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        items[index],
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _showEditItemDialog(title, items, index),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(LucideIcons.pencil, size: 14, color: Color(0xFF6B7280)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _removeItem(items, index),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
