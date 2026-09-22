import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';

class MacOsBarcodeGenPage extends StatefulWidget {
  const MacOsBarcodeGenPage({super.key});

  @override
  State<MacOsBarcodeGenPage> createState() => _MacOsBarcodeGenPageState();
}

class _MacOsBarcodeGenPageState extends State<MacOsBarcodeGenPage> {
  // Preset templates
  int _selectedPresetIndex = 0;
  final List<Map<String, dynamic>> _presetTemplates = [
    {
      'title': 'Standard Retail Label',
      'subtitle': 'Balanced product label with header, multi-field grid, barcode & price tag',
      'icon': LucideIcons.layoutGrid,
    },
    {
      'title': 'Logistics & Asset Badge',
      'subtitle': 'Bold SKU header, prominent barcode, and 2-column specifications table',
      'icon': LucideIcons.box,
    },
    {
      'title': 'QR Code Spec Tag',
      'subtitle': 'Side-by-side high density QR code with comprehensive custom attributes list',
      'icon': LucideIcons.qrCode,
    },
    {
      'title': 'Compact Price Sticker',
      'subtitle': 'Clean minimal sticker focused on product title, barcode and price tag',
      'icon': LucideIcons.tag,
    },
    {
      'title': 'Jewelry & Small Item Tag',
      'subtitle': 'Ultra-compact dual column format ideal for small items, rings and accessories',
      'icon': LucideIcons.sparkles,
    },
    {
      'title': 'Custom Template',
      'subtitle': 'Fully personalized layout with store logo, custom badge, border & discount styling',
      'icon': LucideIcons.pencil,
    },
  ];

  // Data Input & Format
  String _generationFormat = 'Code 128 (Standard)';
  final TextEditingController _codeValueController = TextEditingController(text: 'CLKS-1001-PROD');
  bool _encodePayload = false;

  // Label Print Info & Pricing
  String _selectedProduct = 'Premium Cotton Shirt';
  final List<Map<String, String>> _sampleProducts = [
    {
      'name': 'Premium Cotton Shirt',
      'title': 'PREMIUM COTTON SHIRT',
      'desc': 'Size: L | Color: Navy',
      'offer': '999.00',
      'mrp': '1299.00',
      'sku': 'CLKS-1001-PROD',
    },
    {
      'name': 'Denim Jeans Slim Fit',
      'title': 'DENIM JEANS SLIM FIT',
      'desc': 'Waist: 32 | Color: Indigo',
      'offer': '1499.00',
      'mrp': '1999.00',
      'sku': 'CLKS-1002-DENIM',
    },
    {
      'name': 'Wireless Earbuds Pro',
      'title': 'WIRELESS EARBUDS PRO',
      'desc': 'ANC | Black Edition',
      'offer': '2499.00',
      'mrp': '3999.00',
      'sku': 'CLKS-1003-AUDIO',
    },
    {
      'name': 'Ergonomic Office Chair',
      'title': 'ERGONOMIC OFFICE CHAIR',
      'desc': 'Mesh Back | Adjustable Armrest',
      'offer': '7499.00',
      'mrp': '9999.00',
      'sku': 'CLKS-1004-FURN',
    },
    {
      'name': 'Organic Green Tea 250g',
      'title': 'ORGANIC GREEN TEA 250G',
      'desc': 'Pure Assam Blend | Fresh Harvest',
      'offer': '349.00',
      'mrp': '450.00',
      'sku': 'CLKS-1005-BEV',
    },
  ];

  late final TextEditingController _productTitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _originalMrpController;

  // Brand Logo & Tag Badge
  String? _uploadedLogoName;
  String _selectedBadge = 'Made in India 🇮🇳';
  final List<String> _badgeOptions = [
    'Made in India 🇮🇳',
    '100% Cotton 👕',
    'Premium Quality ⭐',
    'Eco Friendly 🌱',
    'Certified Safe 🛡️',
    'Best Seller 🔥',
    'No Badge',
  ];

  // Custom Keys & Values
  bool _isGridView = false;
  final List<Map<String, String>> _customFields = [
    {'key': 'Exp Date', 'value': '12/2026'},
    {'key': 'Weight', 'value': '500g'},
    {'key': 'Batch No', 'value': 'B-2026-X'},
  ];

  final List<String> _quickAddKeys = [
    'Exp Date',
    'Weight',
    'Batch No',
    'Material',
    'Serial No',
    'MRP',
    'Mfg Date',
    'Origin',
  ];

  // Dimensions & Custom Canvas Styling
  double _widthScale = 2.0;
  double _heightPx = 90.0;
  double _fontSize = 15.0;
  bool _showCodeValueText = true;

  Color _barColor = Colors.black;
  String _barColorHex = '#000000';

  Color _bgTintColor = Colors.white;
  String _bgTintHex = '#ffffff';

  @override
  void initState() {
    super.initState();
    _productTitleController = TextEditingController(text: 'PREMIUM COTTON SHIRT');
    _descriptionController = TextEditingController(text: 'Size: L | Color: Navy');
    _priceController = TextEditingController(text: '999.00');
    _originalMrpController = TextEditingController(text: '1299.00');
  }

  @override
  void dispose() {
    _codeValueController.dispose();
    _productTitleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalMrpController.dispose();
    super.dispose();
  }

  String _calculateDiscount() {
    final mrp = double.tryParse(_originalMrpController.text) ?? 0.0;
    final offer = double.tryParse(_priceController.text) ?? 0.0;
    if (mrp > 0 && offer < mrp) {
      final pct = ((mrp - offer) / mrp * 100).round();
      return '$pct% OFF';
    }
    return '0% OFF';
  }

  void _onProductSelected(String productName) {
    setState(() {
      _selectedProduct = productName;
      final matched = _sampleProducts.firstWhere(
        (p) => p['name'] == productName,
        orElse: () => _sampleProducts[0],
      );
      _productTitleController.text = matched['title'] ?? '';
      _descriptionController.text = matched['desc'] ?? '';
      _priceController.text = matched['offer'] ?? '';
      _originalMrpController.text = matched['mrp'] ?? '';
      _codeValueController.text = matched['sku'] ?? '';
    });
  }

  void _addQuickKey(String key) {
    if (_customFields.length >= 25) return;
    setState(() {
      String defaultValue = '';
      if (key == 'Exp Date') defaultValue = '12/2026';
      if (key == 'Weight') defaultValue = '500g';
      if (key == 'Batch No') defaultValue = 'B-2026-X';
      if (key == 'Material') defaultValue = '100% Cotton';
      if (key == 'Serial No') defaultValue = 'SN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      if (key == 'MRP') defaultValue = '₹${_originalMrpController.text}';
      if (key == 'Mfg Date') defaultValue = '01/2026';
      if (key == 'Origin') defaultValue = 'India';

      _customFields.add({'key': key, 'value': defaultValue});
    });
  }

  void _addNewCustomField() {
    if (_customFields.length >= 25) return;
    setState(() {
      _customFields.add({'key': '', 'value': ''});
    });
  }

  void _removeCustomField(int index) {
    setState(() {
      _customFields.removeAt(index);
    });
  }

  void _clearAllCustomFields() {
    setState(() {
      _customFields.clear();
    });
  }

  void _showCsvUploadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.fileSpreadsheet, color: Color(0xFF15803D), size: 18),
            ),
            const SizedBox(width: 12),
            const Text('Bulk CSV Label Upload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload a spreadsheet containing catalog inventory to generate barcode labels in bulk with custom attributes.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.fileSpreadsheet, size: 32, color: Color(0xFF16A34A)),
                    const SizedBox(height: 8),
                    const Text('Drag & Drop CSV File here or Browse', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('Supported formats: .CSV, .XLSX (Max 10MB)', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        AppSnackbar.show(context, 'Sample spreadsheet template loaded (12 items ready).', type: SnackType.success);
                      },
                      icon: const Icon(LucideIcons.upload, size: 13),
                      label: const Text('Select File', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14532D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showColorPickerModal(bool isBackground) {
    final colors = isBackground
        ? [
            {'hex': '#ffffff', 'color': Colors.white},
            {'hex': '#f8fafc', 'color': const Color(0xFFF8FAFC)},
            {'hex': '#fef9c3', 'color': const Color(0xFFFEF9C3)},
            {'hex': '#f0fdf4', 'color': const Color(0xFFF0FDF4)},
            {'hex': '#fff1f2', 'color': const Color(0xFFFFF1F2)},
          ]
        : [
            {'hex': '#000000', 'color': Colors.black},
            {'hex': '#1e3a8a', 'color': const Color(0xFF1E3A8A)},
            {'hex': '#14532d', 'color': const Color(0xFF14532D)},
            {'hex': '#7c2d12', 'color': const Color(0xFF7C2D12)},
            {'hex': '#4c1d95', 'color': const Color(0xFF4C1D95)},
          ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isBackground ? 'Select Background Tint' : 'Select Barcode Color', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) {
            final color = c['color'] as Color;
            final hex = c['hex'] as String;
            return InkWell(
              onTap: () {
                setState(() {
                  if (isBackground) {
                    _bgTintColor = color;
                    _bgTintHex = hex;
                  } else {
                    _barColor = color;
                    _barColorHex = hex;
                  }
                });
                Navigator.pop(ctx);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── TOP HEADER ───
            _buildTopHeader(),

            const SizedBox(height: 20),

            // ─── TWO-COLUMN MAIN WORKSPACE ───
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1060;

                if (!isWide) {
                  // Stacked vertically on compact screens to avoid horizontal overflow
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLeftConfigurationColumn(),
                      const SizedBox(height: 24),
                      _buildRightLiveCanvasColumn(),
                    ],
                  );
                }

                // 2-column layout matching reference screenshots
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 62,
                      child: _buildLeftConfigurationColumn(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 38,
                      child: _buildRightLiveCanvasColumn(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP HEADER & ACTION BUTTONS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Barcode Generator',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Generate high-resolution product labels, QR codes & multi-attribute tags instantly.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Action Buttons Row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bulk CSV Upload (0)
            OutlinedButton.icon(
              onPressed: _showCsvUploadDialog,
              icon: const Icon(LucideIcons.fileSpreadsheet, size: 14, color: Color(0xFF15803D)),
              label: const Text(
                'Bulk CSV Upload (0)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF16A34A), width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(width: 10),

            // Print View
            OutlinedButton.icon(
              onPressed: () {
                AppSnackbar.show(
                  context,
                  "Sending label '${_productTitleController.text}' to system print view...",
                  type: SnackType.info,
                );
              },
              icon: const Icon(LucideIcons.printer, size: 14, color: Color(0xFF334155)),
              label: const Text(
                'Print View',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(width: 10),

            // Download PNG
            ElevatedButton.icon(
              onPressed: () {
                AppSnackbar.show(
                  context,
                  "Downloaded high-resolution label PNG: ${_codeValueController.text}.png",
                  type: SnackType.success,
                );
              },
              icon: const Icon(LucideIcons.download, size: 14, color: Colors.white),
              label: const Text(
                'Download PNG',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14532D),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LEFT CONFIGURATION COLUMN (Cards 1, 2, 3, 4)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLeftConfigurationColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPresetLayoutCard(),
        const SizedBox(height: 18),
        _buildDataInputCard(),
        const SizedBox(height: 18),
        _buildLabelPrintInfoCard(),
        const SizedBox(height: 18),
        _buildDimensionsStylingCard(),
      ],
    );
  }

  // ─── CARD 1: SELECT CANVAS LABEL PRESET LAYOUT ───
  Widget _buildPresetLayoutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(LucideIcons.layoutTemplate, color: Color(0xFF16A34A), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Select Canvas Label Preset Layout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '6 Canvas Templates Available',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Presets Grid Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int itemsInRow = 5;
              if (width < 600) {
                itemsInRow = 1;
              } else if (width < 820) {
                itemsInRow = 2;
              } else if (width < 1100) {
                itemsInRow = 3;
              }

              final spacing = 12.0;
              final cardWidth = (width - (itemsInRow - 1) * spacing) / itemsInRow;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(_presetTemplates.length, (idx) {
                  final preset = _presetTemplates[idx];
                  final isSelected = _selectedPresetIndex == idx;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPresetIndex = idx;
                        if (idx == 2) {
                          _generationFormat = 'QR Code';
                        } else if (idx == 0 || idx == 1 || idx == 3 || idx == 4) {
                          _generationFormat = 'Code 128 (Standard)';
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: cardWidth,
                      constraints: const BoxConstraints(minHeight: 120),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF14532D) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  preset['icon'] as IconData,
                                  size: 16,
                                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                                ),
                              ),
                              if (isSelected)
                                const Icon(LucideIcons.checkCircle2, color: Color(0xFF16A34A), size: 16),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            preset['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preset['subtitle'] as String,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── CARD 2: DATA INPUT & FORMAT ───
  Widget _buildDataInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.scan, color: Color(0xFF16A34A), size: 18),
              SizedBox(width: 8),
              Text(
                'Data Input & Format',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Generation Format Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generation Format',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _generationFormat,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 15, color: Color(0xFF64748B)),
                          items: ['Code 128 (Standard)', 'EAN-13', 'QR Code', 'UPC-A', 'Code 39']
                              .map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _generationFormat = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Code Value (SKU / ID)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Code Value (SKU / ID)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _codeValueController,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Checkbox container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                    value: _encodePayload,
                    activeColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _encodePayload = val ?? false),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Encode Title, Price & Custom Attributes directly inside QR/Barcode payload',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD 3: LABEL PRINT INFORMATION & PRICING ───
  Widget _buildLabelPrintInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.type, color: Color(0xFF16A34A), size: 18),
              SizedBox(width: 8),
              Text(
                'Label Print Information & Pricing',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Product Title / Name Dropdown Selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product Title / Name',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedProduct,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 15, color: Color(0xFF64748B)),
                    items: _sampleProducts
                        .map((p) => DropdownMenuItem(
                              value: p['name'],
                              child: Text(p['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) _onProductSelected(val);
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Description / Variation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description / Variation',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Center(
                  child: TextField(
                    controller: _descriptionController,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Offer Price & Original MRP
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OFFER PRICE (₹)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _priceController,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
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
                    const Text(
                      'ORIGINAL MRP (₹)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _originalMrpController,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Sub-Section: Brand Store Logo & Quality Badge
          Row(
            children: const [
              Text('🏷️', style: TextStyle(fontSize: 12)),
              SizedBox(width: 6),
              Text(
                'BRAND STORE LOGO & QUALITY BADGE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Store Logo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Store Logo',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() => _uploadedLogoName = 'logo_retail.png');
                              AppSnackbar.show(context, 'Store logo attached: logo_retail.png', type: SnackType.info);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: const Color(0xFF0F172A),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                            ),
                            child: const Text('Choose file', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _uploadedLogoName ?? 'No file chosen',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Recommended image size: 200 × 200 px',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Tag Badge Icon
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tag Badge Icon',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBadge,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 15, color: Color(0xFF64748B)),
                          items: _badgeOptions
                              .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedBadge = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Sub-Section: Custom Keys & Values
          Text(
            'CUSTOM KEYS & VALUES (${_customFields.length} / 25 ASSIGNED)',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Assign multiple custom attributes to render on the barcode canvas.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 12),

          // Action row: Clear All, Grid/List toggle, + Add Key-Value
          Row(
            children: [
              // Clear All
              OutlinedButton(
                onPressed: _clearAllCustomFields,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Clear All (${_customFields.length})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                ),
              ),

              const SizedBox(width: 10),

              // View Toggle (Grid / List)
              Container(
                height: 34,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _isGridView = true),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isGridView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _isGridView
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Icon(LucideIcons.layoutGrid, size: 14, color: _isGridView ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _isGridView = false),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: !_isGridView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: !_isGridView
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Icon(LucideIcons.list, size: 14, color: !_isGridView ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // + Add Key-Value
              ElevatedButton.icon(
                onPressed: _addNewCustomField,
                icon: const Icon(LucideIcons.plus, size: 13, color: Colors.white),
                label: const Text('+ Add Key-Value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14532D),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quick Add Pills Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Quick Add: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              const SizedBox(width: 6),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _quickAddKeys.map((key) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: InkWell(
                          onTap: () => _addQuickKey(key),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+ $key',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Custom Fields Rows List
          Column(
            children: List.generate(_customFields.length, (idx) {
              final field = _customFields[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    // Key
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Center(
                          child: TextFormField(
                            initialValue: field['key'],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(
                              hintText: 'Label Key',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              _customFields[idx]['key'] = val;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Value
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Center(
                          child: TextFormField(
                            initialValue: field['value'],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(
                              hintText: 'Value',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              _customFields[idx]['value'] = val;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Trash Action
                    InkWell(
                      onTap: () => _removeCustomField(idx),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Icon(LucideIcons.trash2, size: 15, color: Color(0xFFDC2626)),
                      ),
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

  // ─── CARD 4: DIMENSIONS & CUSTOM CANVAS STYLING ───
  Widget _buildDimensionsStylingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.sliders, color: Color(0xFF16A34A), size: 18),
              SizedBox(width: 8),
              Text(
                'Dimensions & Custom Canvas Styling',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Row 1: Width Scale & Height (px)
          Row(
            children: [
              Expanded(
                child: _buildSliderTile(
                  label: 'Width Scale',
                  value: _widthScale,
                  min: 1.0,
                  max: 4.0,
                  displayValue: '${_widthScale.toStringAsFixed(0)}x',
                  onChanged: (val) => setState(() => _widthScale = val),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildSliderTile(
                  label: 'Height (px)',
                  value: _heightPx,
                  min: 40.0,
                  max: 180.0,
                  displayValue: '${_heightPx.toInt()}px',
                  onChanged: (val) => setState(() => _heightPx = val),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Font Size & Text Label Checkbox
          Row(
            children: [
              Expanded(
                child: _buildSliderTile(
                  label: 'Font Size',
                  value: _fontSize,
                  min: 10.0,
                  max: 24.0,
                  displayValue: '${_fontSize.toInt()}px',
                  onChanged: (val) => setState(() => _fontSize = val),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Text Label', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _showCodeValueText,
                            activeColor: const Color(0xFF16A34A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => setState(() => _showCodeValueText = val ?? true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Show code value text',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 3: Bar / QR Color & Background Tint
          Row(
            children: [
              // Bar / QR Color
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bar / QR Color', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _showColorPickerModal(false),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _barColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _barColorHex,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'monospace', color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Background Tint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Background Tint', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _showColorPickerModal(true),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _bgTintColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _bgTintHex,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'monospace', color: Color(0xFF0F172A)),
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
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            Text(displayValue, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            activeTrackColor: const Color(0xFF14532D),
            inactiveTrackColor: const Color(0xFFE2E8F0),
            thumbColor: const Color(0xFF14532D),
            overlayColor: const Color(0xFF14532D).withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RIGHT COLUMN: LIVE CANVAS PREVIEW & PRO TIP
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRightLiveCanvasColumn() {
    final activePreset = _presetTemplates[_selectedPresetIndex]['title'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live Canvas Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top simulated bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    const Text(
                      'LIVE CANVAS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        activePreset,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Window dots
                    Row(
                      children: [
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      ],
                    ),
                  ],
                ),
              ),

              // Checkerboard Canvas Area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                child: CustomPaint(
                  painter: _CheckerboardPainter(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      children: [
                        // The Rendered Label Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _bgTintColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Country Badge
                              if (_selectedBadge != 'No Badge')
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFBBF7D0)),
                                    ),
                                    child: Text(
                                      _selectedBadge,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 6),

                              // Product Title
                              Text(
                                _productTitleController.text.toUpperCase(),
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 4),

                              // Description / Variation
                              Text(
                                _descriptionController.text,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              if (_customFields.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                // 2-Column Custom Attributes Grid
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left column (even indices)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 0; i < _customFields.length; i += 2)
                                            if (_customFields[i]['key']!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 3.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '${_customFields[i]['key']}: ',
                                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                                      ),
                                                      TextSpan(
                                                        text: _customFields[i]['value'],
                                                        style: const TextStyle(fontSize: 10, color: Color(0xFF334155)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Right column (odd indices)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          for (int i = 1; i < _customFields.length; i += 2)
                                            if (_customFields[i]['key']!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 3.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '${_customFields[i]['key']}: ',
                                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                                      ),
                                                      TextSpan(
                                                        text: _customFields[i]['value'],
                                                        style: const TextStyle(fontSize: 10, color: Color(0xFF334155)),
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
                              ],

                              const SizedBox(height: 14),

                              // Barcode / QR Code Graphic
                              _generationFormat == 'QR Code'
                                  ? SizedBox(
                                      height: _heightPx,
                                      width: _heightPx,
                                      child: CustomPaint(
                                        painter: _QrCodePainter(
                                          data: _codeValueController.text,
                                          color: _barColor,
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: _heightPx,
                                      width: double.infinity,
                                      child: CustomPaint(
                                        painter: _BarcodePainter(
                                          sku: _codeValueController.text,
                                          scale: _widthScale,
                                          barColor: _barColor,
                                        ),
                                      ),
                                    ),

                              const SizedBox(height: 4),

                              // SKU text below barcode
                              if (_showCodeValueText)
                                Text(
                                  _codeValueController.text,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),

                              const SizedBox(height: 14),

                              // Divider
                              Container(
                                height: 1,
                                color: const Color(0xFFE2E8F0),
                              ),

                              const SizedBox(height: 12),

                              // Price & Discount Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '₹ ${_originalMrpController.text}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF94A3B8),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹ ${_priceController.text}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _calculateDiscount(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Format tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            'Format: ${_generationFormat.toUpperCase().replaceAll(' (STANDARD)', '')}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Pro Labeling Tip Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBAE6FD)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(LucideIcons.sparkles, color: Color(0xFF0284C7), size: 16),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pro Labeling Tip',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Select stock products above or upload CSV spreadsheets to generate labels in bulk with strikethrough MRP & store badges.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF0284C7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTER: CHECKERBOARD CANVAS
// ═══════════════════════════════════════════════════════════════
class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()..color = const Color(0xFFF8FAFC);
    final darkPaint = Paint()..color = const Color(0xFFF1F5F9);
    const cellSize = 12.0;

    for (double y = 0; y < size.height; y += cellSize) {
      for (double x = 0; x < size.width; x += cellSize) {
        final isEven = ((x / cellSize).floor() + (y / cellSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, cellSize, cellSize),
          isEven ? lightPaint : darkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTER: BARCODE (CODE 128)
// ═══════════════════════════════════════════════════════════════
class _BarcodePainter extends CustomPainter {
  final String sku;
  final double scale;
  final Color barColor;

  _BarcodePainter({
    required this.sku,
    required this.scale,
    this.barColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final seed = sku.hashCode;
    final random = _Lcg(seed);

    double currentX = 12.0;
    final endX = size.width - 12.0;

    // Start guard
    canvas.drawRect(Rect.fromLTWH(currentX, 0, 2.5 * scale, size.height), paint);
    currentX += 4.5 * scale;
    canvas.drawRect(Rect.fromLTWH(currentX, 0, 1.5 * scale, size.height), paint);
    currentX += 3.5 * scale;

    while (currentX < endX - 10.0 * scale) {
      final barWidth = ((random.nextInt(3) + 1) * 1.1) * scale;
      final spaceWidth = ((random.nextInt(3) + 1) * 1.1) * scale;

      if (currentX + barWidth > endX - 8.0 * scale) break;

      canvas.drawRect(
        Rect.fromLTWH(currentX, 0, barWidth, size.height),
        paint,
      );

      currentX += barWidth + spaceWidth;
    }

    // End guard
    if (endX - currentX > 6.0 * scale) {
      canvas.drawRect(Rect.fromLTWH(endX - 5.0 * scale, 0, 1.5 * scale, size.height), paint);
      canvas.drawRect(Rect.fromLTWH(endX - 2.5 * scale, 0, 2.5 * scale, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) =>
      oldDelegate.sku != sku || oldDelegate.scale != scale || oldDelegate.barColor != barColor;
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTER: REALISTIC QR CODE
// ═══════════════════════════════════════════════════════════════
class _QrCodePainter extends CustomPainter {
  final String data;
  final Color color;

  _QrCodePainter({required this.data, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dimension = size.shortestSide;
    final moduleSize = dimension / 25;

    // Draw finder patterns (top-left, top-right, bottom-left)
    void drawFinderPattern(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 7 * moduleSize, 7 * moduleSize), paint);
      canvas.drawRect(
        Rect.fromLTWH(x + moduleSize, y + moduleSize, 5 * moduleSize, 5 * moduleSize),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + 2 * moduleSize, y + 2 * moduleSize, 3 * moduleSize, 3 * moduleSize),
        paint,
      );
    }

    drawFinderPattern(0, 0);
    drawFinderPattern(18 * moduleSize, 0);
    drawFinderPattern(0, 18 * moduleSize);

    // Data modules
    final rand = _Lcg(data.hashCode);
    for (int r = 0; r < 25; r++) {
      for (int c = 0; c < 25; c++) {
        if ((r < 8 && c < 8) || (r < 8 && c > 16) || (r > 16 && c < 8)) continue;
        if (rand.nextInt(100) > 55) {
          canvas.drawRect(
            Rect.fromLTWH(c * moduleSize, r * moduleSize, moduleSize, moduleSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrCodePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

class _Lcg {
  int _seed;
  _Lcg(this._seed);

  int nextInt(int bound) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % bound;
  }
}
