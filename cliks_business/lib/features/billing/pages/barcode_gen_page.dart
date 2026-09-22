import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/app_ui_kit.dart';
import 'macos_barcode_gen_page.dart';

class BarcodeGenPage extends StatefulWidget {
  const BarcodeGenPage({super.key});

  @override
  State<BarcodeGenPage> createState() => _BarcodeGenPageState();
}

class _BarcodeGenPageState extends State<BarcodeGenPage> {

  // Input fields state
  String _generationFormat = 'Code 128 (Standard)';
  final TextEditingController _codeValueController = TextEditingController(text: 'CLKS-1001-PROD');
  final TextEditingController _productTitleController = TextEditingController(text: 'PREMIUM COTTON SHIRT');
  final TextEditingController _descriptionController = TextEditingController(text: 'Size: L | Color: Navy');
  final TextEditingController _priceController = TextEditingController(text: '999.00');

  // Custom fields state
  final List<Map<String, String>> _customFields = [
    {'key': 'Exp Date', 'value': '12/2026'}
  ];

  // Styling state
  double _widthScale = 2.0;
  double _heightPx = 100.0;
  double _fontSize = 16.0;
  bool _displayHumanReadableText = true;

  @override
  void dispose() {
    _codeValueController.dispose();
    _productTitleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addNewField() {
    setState(() {
      _customFields.add({'key': '', 'value': ''});
    });
  }

  void _removeField(int index) {
    setState(() {
      _customFields.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 950;
    final isMacOS = Theme.of(context).platform == TargetPlatform.macOS;
    if (isMacOS) {
      return const MacOsBarcodeGenPage();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HERO SUMMARY CARD (Accounting Style Header with Top Action Buttons) ───
          SliverToBoxAdapter(
            child: isMacOS
                ? _buildHeroSummary(isMobile)
                : _buildHeroSummary(isMobile)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.05, end: 0),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 14),
          ),

          // ─── MAIN CONTENT AREA ───
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 24,
              0,
              isMobile ? 14 : 24,
              isMobile ? 40 : 40,
            ),
            sliver: SliverToBoxAdapter(
              child: isMacOS
                  ? _buildMainContent(isMobile)
                  : _buildMainContent(isMobile)
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 150.ms),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO SUMMARY CARD (Accounting Style Header with Action Buttons)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroSummary(bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 14 : 24, isMobile ? 12 : 16, isMobile ? 14 : 24, 0),
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title Row with Integrated Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.scan, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'BARCODE & LABEL GENERATOR',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.checkCircle2, size: 13, color: Colors.greenAccent.shade100),
                    const SizedBox(width: 4),
                    Text(
                      'READY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent.shade100,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2 Action Buttons Placed Inside Top Hero Card (as requested)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppSnackbar.show(
                      context,
                      "Sending barcode format '$_generationFormat' to printer...",
                      type: SnackType.info,
                    );
                  },
                  icon: const Icon(LucideIcons.printer, size: 13, color: Colors.white),
                  label: const Text('Print View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppSnackbar.show(
                      context,
                      "Downloaded barcode image: ${_codeValueController.text}.png",
                      type: SnackType.success,
                    );
                  },
                  icon: const Icon(LucideIcons.download, size: 13),
                  label: const Text('Download PNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.stylishDarkGreen,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3 Stat Chips inside hero card
          Row(
            children: [
              _buildHeroChip('Active Format', 'Code 128', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Label Quality', '300 DPI', isMobile),
              const SizedBox(width: 8),
              _buildHeroChip('Canvas Mode', 'Live Preview', isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String label, String value, bool isMobile) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 8.5 : 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ═══════════════════════════════════════════════════════════════
  // MAIN CONTENT ROUTER WITH ACCOUNTING STYLE CARD CONTAINER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMainContent(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Barcode & Label Generator',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.stylishDarkGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActiveTabSection(isMobile),
        ],
      ),
    );
  }

  Widget _buildActiveTabSection(bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLiveCanvasCard(),
          const SizedBox(height: 24),
          _buildDataInputCard(),
          const SizedBox(height: 24),
          _buildLabelPrintDataCard(),
          const SizedBox(height: 24),
          _buildDimensionsStylingCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDataInputCard(),
              const SizedBox(height: 24),
              _buildLabelPrintDataCard(),
              const SizedBox(height: 24),
              _buildDimensionsStylingCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildLiveCanvasCard(),
        ),
      ],
    );
  }

  Widget _buildDataInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                child: const Icon(LucideIcons.scan, color: Color(0xFF15803D), size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Data Input Parameters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Generation Format', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _generationFormat,
                          isExpanded: true,
                          items: ['Code 128 (Standard)', 'EAN-13', 'QR Code']
                              .map((f) => DropdownMenuItem(value: f, child: Text(f, style: const TextStyle(fontSize: 12))))
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
              Expanded(
                child: _buildInputField('Code Value (SKU/ID)', _codeValueController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabelPrintDataCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                child: const Icon(LucideIcons.type, color: Color(0xFF1D4ED8), size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Label Print Metadata', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField('Product Title / Name', _productTitleController),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInputField('Description / Variation', _descriptionController),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildInputField('Price Tag', _priceController, prefix: '₹'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CUSTOM FIELDS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              TextButton.icon(
                onPressed: _addNewField,
                icon: const Icon(LucideIcons.plus, size: 12),
                label: const Text('Add Field', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF166534),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: List.generate(_customFields.length, (idx) {
              final item = _customFields[idx];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Label Key'),
                          onChanged: (val) {
                            _customFields[idx]['key'] = val;
                            setState(() {});
                          },
                          controller: TextEditingController(text: item['key'])..selection = TextSelection.fromPosition(TextPosition(offset: item['key']!.length)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Label Value'),
                          onChanged: (val) {
                            _customFields[idx]['value'] = val;
                            setState(() {});
                          },
                          controller: TextEditingController(text: item['value'])..selection = TextSelection.fromPosition(TextPosition(offset: item['value']!.length)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _removeField(idx),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(LucideIcons.trash2, size: 14, color: Colors.red),
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

  Widget _buildDimensionsStylingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(6)),
                child: const Icon(LucideIcons.sliders, color: Colors.purple, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Dimensions & Styling', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final useVertical = constraints.maxWidth < 420;
              final child1 = _buildSliderField('Width Scale', _widthScale, 1.0, 4.0, '${_widthScale.toStringAsFixed(1)}x', (val) {
                setState(() => _widthScale = val);
              });
              final child2 = _buildSliderField('Height (px)', _heightPx, 50.0, 200.0, '${_heightPx.toInt()}px', (val) {
                setState(() => _heightPx = val);
              });
              final child3 = _buildSliderField('Font Size', _fontSize, 10.0, 24.0, '${_fontSize.toInt()}px', (val) {
                setState(() => _fontSize = val);
              });
              final child4 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Text Label', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Checkbox(
                        value: _displayHumanReadableText,
                        activeColor: const Color(0xFF166534),
                        onChanged: (val) {
                          if (val != null) setState(() => _displayHumanReadableText = val);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Display human readable text',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              );

              if (useVertical) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    child1,
                    const SizedBox(height: 16),
                    child2,
                    const SizedBox(height: 16),
                    child3,
                    const SizedBox(height: 16),
                    child4,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: child1),
                      const SizedBox(width: 16),
                      Expanded(child: child2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: child3),
                      const SizedBox(width: 16),
                      Expanded(child: child4),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCanvasCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Simulated Window Title Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                const Text('LIVE CANVAS PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                const Spacer(),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  ],
                ),
              ],
            ),
          ),

          // Label Preview
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _productTitleController.text.toUpperCase(),
                    style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _descriptionController.text,
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  if (_customFields.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ..._customFields.where((f) => f['key']!.isNotEmpty).map((f) => Text(
                          '${f['key']}: ${f['value']}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        )),
                  ],
                  const SizedBox(height: 16),

                  // Dynamic Custom Painted Barcode
                  SizedBox(
                    height: _heightPx,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _BarcodePainter(
                        sku: _codeValueController.text,
                        scale: _widthScale,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  if (_displayHumanReadableText)
                    Text(
                      _codeValueController.text,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),

                  const SizedBox(height: 12),
                  Text(
                    '₹ ${_priceController.text}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Format: ${_generationFormat.toUpperCase().replaceAll(' (STANDARD)', '')}',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Pro Tip Banner
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.info, size: 14, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pro Tip\nEnsure contrast ratio between Bar color and Background is high to guarantee successful optical scans.',
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade800, height: 1.4, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 6),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                Text(prefix, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderField(String label, double val, double min, double max, String displayVal, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
            Text(displayVal, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2.5,
            activeTrackColor: const Color(0xFF166534),
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: const Color(0xFF166534),
            overlayColor: const Color(0xFF166534).withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: val,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// Custom Painter to draw realistic barcode bars
class _BarcodePainter extends CustomPainter {
  final String sku;
  final double scale;

  _BarcodePainter({required this.sku, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final seed = sku.hashCode;
    final random = _Lcg(seed);

    double currentX = 10.0;
    final endX = size.width - 10.0;

    while (currentX < endX) {
      final barWidth = (random.nextInt(3) + 1) * scale;
      final spaceWidth = (random.nextInt(3) + 1) * scale;

      if (currentX + barWidth > endX) break;

      canvas.drawRect(
        Rect.fromLTWH(currentX, 0, barWidth, size.height),
        paint,
      );

      currentX += barWidth + spaceWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Lcg {
  int _seed;
  _Lcg(this._seed);

  int nextInt(int bound) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % bound;
  }
}


