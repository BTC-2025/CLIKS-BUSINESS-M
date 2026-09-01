import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════

class TapeEntry {
  final String id;
  final String operator; // '=', '+', '-', '+GST', '-DISC', '×', '÷'
  final double value;
  final double runningTotal;
  String? label;
  final bool isBase;
  final String? presetTag;

  TapeEntry({
    required this.id,
    required this.operator,
    required this.value,
    required this.runningTotal,
    this.label,
    this.isBase = false,
    this.presetTag,
  });
}

class ComparisonRow {
  String description;
  double? valueA;
  double? valueB;
  double qtyA;
  double qtyB;
  double discountA;
  double discountB;

  ComparisonRow({
    this.description = '',
    this.valueA,
    this.valueB,
    this.qtyA = 1.0,
    this.qtyB = 1.0,
    this.discountA = 0.0,
    this.discountB = 0.0,
  });

  double get finalA {
    final base = (valueA ?? 0.0) * qtyA;
    return base - (base * (discountA / 100.0));
  }

  double get finalB {
    final base = (valueB ?? 0.0) * qtyB;
    return base - (base * (discountB / 100.0));
  }
}

class HistorySection {
  final String id;
  final DateTime timestamp;
  final List<TapeEntry>? tapeEntries;
  final List<ComparisonRow>? comparisonRows;
  final String type; // 'tape' or 'compare'
  final double totalValue;

  HistorySection({
    required this.id,
    required this.timestamp,
    this.tapeEntries,
    this.comparisonRows,
    required this.type,
    required this.totalValue,
  });
}

// ═══════════════════════════════════════════════════════════
// BETA CALCULATOR WIDGET
// ═══════════════════════════════════════════════════════════

class BetaCalculator extends StatefulWidget {
  const BetaCalculator({super.key});

  @override
  State<BetaCalculator> createState() => _BetaCalculatorState();
}

class _BetaCalculatorState extends State<BetaCalculator> {
  final ScrollController _tapeScrollController = ScrollController();

  // State
  List<TapeEntry> _tapeEntries = [];
  List<ComparisonRow> _comparisonRows = [];
  final List<HistorySection> _historyLog = [];
  bool _showHistoryList = false;

  String _currentInput = '0';
  String _pendingOperator = '=';
  double _runningTotal = 0.0;
  bool _hasBase = false;
  bool _isUsdMode = false;
  final double _usdRate = 83.5;

  // Active Mode: 'gst', 'discount', 'compare'
  String _activeMode = 'gst';

  // Compare inputs
  final TextEditingController _compDescController = TextEditingController();
  final TextEditingController _compValAController = TextEditingController();
  final TextEditingController _compValBController = TextEditingController();
  final TextEditingController _compQtyAController = TextEditingController();
  final TextEditingController _compQtyBController = TextEditingController();
  final TextEditingController _compDiscAController = TextEditingController();
  final TextEditingController _compDiscBController = TextEditingController();

  @override
  void dispose() {
    _tapeScrollController.dispose();
    _compDescController.dispose();
    _compValAController.dispose();
    _compValBController.dispose();
    _compQtyAController.dispose();
    _compQtyBController.dispose();
    _compDiscAController.dispose();
    _compDiscBController.dispose();
    super.dispose();
  }

  void _scrollTapeToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tapeScrollController.hasClients) {
        _tapeScrollController.animateTo(
          _tapeScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Calculator Logic
  void _enterDigit(String digit) {
    setState(() {
      if (_currentInput == '0' && digit != '.') {
        _currentInput = digit;
      } else {
        if (digit == '.' && _currentInput.contains('.')) return;
        _currentInput += digit;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_currentInput.length > 1) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      } else {
        _currentInput = '0';
      }
    });
  }

  void _clearAll() {
    setState(() {
      _currentInput = '0';
      _pendingOperator = '=';
      _runningTotal = 0.0;
      _hasBase = false;
      _tapeEntries.clear();
      _comparisonRows.clear();
    });
  }

  void _setOperator(String op) {
    final value = double.tryParse(_currentInput) ?? 0.0;
    if (!_hasBase && value == 0.0 && _tapeEntries.isEmpty) return;

    setState(() {
      if (!_hasBase) {
        // Set Base Amount
        _runningTotal = value;
        _hasBase = true;
        _tapeEntries.add(TapeEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          operator: '=',
          value: value,
          runningTotal: value,
          isBase: true,
        ));
      } else {
        // Apply pending operation
        _applyOperation(value);
      }
      _pendingOperator = op;
      _currentInput = '0';
    });
    _scrollTapeToBottom();
  }

  void _applyOperation(double value) {
    double oldTotal = _runningTotal;
    switch (_pendingOperator) {
      case '+':
        _runningTotal += value;
        break;
      case '-':
        _runningTotal -= value;
        break;
      case '×':
        _runningTotal *= value;
        break;
      case '÷':
        if (value != 0) _runningTotal /= value;
        break;
    }
    _tapeEntries.add(TapeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operator: _pendingOperator,
      value: value,
      runningTotal: _runningTotal,
    ));
  }

  void _calculate() {
    final value = double.tryParse(_currentInput) ?? 0.0;
    if (!_hasBase) return;
    setState(() {
      _applyOperation(value);
      _pendingOperator = '=';
      _currentInput = '0';
    });
    _scrollTapeToBottom();
  }

  // Presets
  void _applyGstPreset(double percentage) {
    if (!_hasBase) return;
    setState(() {
      final gstValue = _runningTotal * (percentage / 100.0);
      _runningTotal += gstValue;
      _tapeEntries.add(TapeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        operator: '+',
        value: gstValue,
        runningTotal: _runningTotal,
        presetTag: '${percentage.toInt()}% GST',
      ));
    });
    _scrollTapeToBottom();
  }

  void _applyDiscountPreset(double percentage) {
    if (!_hasBase) return;
    setState(() {
      final discValue = _runningTotal * (percentage / 100.0);
      _runningTotal -= discValue;
      _tapeEntries.add(TapeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        operator: '-',
        value: discValue,
        runningTotal: _runningTotal,
        presetTag: '${percentage.toInt()}% Disc',
      ));
    });
    _scrollTapeToBottom();
  }

  // Label management
  void _addLabel(int idx, String label) {
    setState(() {
      _tapeEntries[idx].label = label;
    });
  }

  // History logs
  void _saveToHistory() {
    if (_tapeEntries.isEmpty && _comparisonRows.isEmpty) return;
    setState(() {
      _historyLog.insert(
        0,
        HistorySection(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          type: _activeMode == 'compare' ? 'compare' : 'tape',
          tapeEntries: List.from(_tapeEntries),
          comparisonRows: List.from(_comparisonRows),
          totalValue: _activeMode == 'compare'
              ? _comparisonRows.fold(0.0, (sum, r) => sum + r.finalA)
              : _runningTotal,
        ),
      );
    });
  }

  void _restoreHistory(HistorySection section) {
    setState(() {
      if (section.type == 'compare') {
        _activeMode = 'compare';
        _comparisonRows = List.from(section.comparisonRows ?? []);
      } else {
        _activeMode = 'gst';
        _tapeEntries = List.from(section.tapeEntries ?? []);
        _runningTotal = section.totalValue;
        _hasBase = _tapeEntries.isNotEmpty;
      }
      _showHistoryList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = _isUsdMode ? '\$' : '₹';
    final displayTotal = _isUsdMode ? _runningTotal / _usdRate : _runningTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Action Bar Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Beta Calc Tape',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondaryText),
            ),
            Row(
              children: [
                _buildActionIcon(LucideIcons.save, 'Save', _saveToHistory),
                _buildActionIcon(
                  _showHistoryList ? LucideIcons.eyeOff : LucideIcons.history,
                  'History',
                  () => setState(() => _showHistoryList = !_showHistoryList),
                ),
                _buildActionIcon(LucideIcons.trash2, 'Clear', _clearAll),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // History logs view
        if (_showHistoryList) ...[
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: _historyLog.isEmpty
                ? const Center(child: Text('No saved logs', style: TextStyle(fontSize: 11, color: Colors.grey)))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _historyLog.length,
                    itemBuilder: (ctx, i) {
                      final log = _historyLog[i];
                      final isComp = log.type == 'compare';
                      double totA = 0;
                      double totB = 0;
                      if (isComp && log.comparisonRows != null) {
                        for (var r in log.comparisonRows!) {
                          totA += r.finalA;
                          totB += r.finalB;
                        }
                      }
                      final logText = isComp 
                          ? 'Compare: A:₹${totA.toStringAsFixed(0)} vs B:₹${totB.toStringAsFixed(0)}'
                          : 'Tape: $currencySymbol${log.totalValue.toStringAsFixed(1)}';

                      return ListTile(
                        dense: true,
                        title: Text(
                          logText,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(LucideIcons.refreshCw, size: 12),
                          onPressed: () => _restoreHistory(log),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
        ],

        // Tape viewer
        if (_activeMode != 'compare') ...[
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: _tapeEntries.isEmpty
                ? const Center(child: Text('Set a base value to begin tape log', style: TextStyle(fontSize: 11, color: Colors.grey)))
                : ListView.builder(
                    controller: _tapeScrollController,
                    itemCount: _tapeEntries.length,
                    itemBuilder: (ctx, idx) {
                      final entry = _tapeEntries[idx];
                      final val = _isUsdMode ? entry.value / _usdRate : entry.value;
                      final rTotal = _isUsdMode ? entry.runningTotal / _usdRate : entry.runningTotal;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${entry.operator} $currencySymbol${val.toStringAsFixed(1)} ${entry.presetTag != null ? '(${entry.presetTag})' : ''}',
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
                            ),
                            Text(
                              '= $currencySymbol${rTotal.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
        ],

        // Base input / Continue Display
        if (_activeMode != 'compare') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  !_hasBase ? 'SET BASE' : 'CONTINUE $_pendingOperator',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                ),
                Text(
                  _currentInput,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Mode switch tabs
        Row(
          children: [
            _buildModeTab('% GST', 'gst'),
            const SizedBox(width: 4),
            _buildModeTab('Discount', 'discount'),
            const SizedBox(width: 4),
            _buildModeTab(currencySymbol, 'currency'),
            const SizedBox(width: 4),
            _buildModeTab('Compare', 'compare'),
          ],
        ),
        const SizedBox(height: 8),

        // Mode subcontent
        if (_activeMode == 'gst')
          Row(
            children: [5, 12, 18, 28].map((p) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: _buildPresetBtn('+$p%', () => _applyGstPreset(p.toDouble()), const Color(0xFF16A34A)),
              ),
            )).toList(),
          )
        else if (_activeMode == 'discount')
          Row(
            children: [5, 10, 20, 50].map((p) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: _buildPresetBtn('-$p%', () => _applyDiscountPreset(p.toDouble()), Colors.red.shade600),
              ),
            )).toList(),
          )
        else if (_activeMode == 'compare')
          _buildCompareSection(),

        const SizedBox(height: 8),

        // Numpad block (only when not in compare mode, or can be general)
        if (_activeMode != 'compare') _buildNumPad(),

        // Total Running display
        if (_activeMode != 'compare') ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RUNNING TOTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                Text(
                  '$currencySymbol${displayTotal.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, size: 14, color: AppColors.secondaryText),
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, String modeKey) {
    final isSelected = modeKey == 'currency' ? false : _activeMode == modeKey;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (modeKey == 'currency') {
            setState(() => _isUsdMode = !_isUsdMode);
          } else {
            setState(() => _activeMode = modeKey);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetBtn(String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildCompareSection() {
    double totalA = 0;
    double totalB = 0;
    for (var r in _comparisonRows) {
      totalA += r.finalA;
      totalB += r.finalB;
    }

    String analysisMsg = '';
    Color bannerColor = Colors.grey.shade400;
    if (totalA < totalB && totalA > 0) {
      final percent = ((totalB - totalA) / totalB * 100).toStringAsFixed(0);
      analysisMsg = 'Side A is cheaper by $percent% (A: ₹${totalA.toStringAsFixed(1)} vs B: ₹${totalB.toStringAsFixed(1)})';
      bannerColor = const Color(0xFF16A34A);
    } else if (totalB < totalA && totalB > 0) {
      final percent = ((totalA - totalB) / totalA * 100).toStringAsFixed(0);
      analysisMsg = 'Side B is cheaper by $percent% (B: ₹${totalB.toStringAsFixed(1)} vs A: ₹${totalA.toStringAsFixed(1)})';
      bannerColor = const Color(0xFF16A34A);
    } else if (totalA == totalB && totalA > 0) {
      analysisMsg = 'Both Side A and Side B are equal';
      bannerColor = AppColors.primaryGreen;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (analysisMsg.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              analysisMsg,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: bannerColor),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        // Table description headers
        const Row(
          children: [
            Expanded(flex: 3, child: Text('DESC', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey))),
            Expanded(flex: 2, child: Text('SIDE A', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey))),
            Expanded(flex: 2, child: Text('SIDE B', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey))),
          ],
        ),
        const Divider(height: 8),

        // Added comparison list
        if (_comparisonRows.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No compared items. Add below:', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
          )
        else
          Column(
            children: _comparisonRows.asMap().entries.map((e) {
              final idx = e.key;
              final r = e.value;
              final valA = r.finalA;
              final valB = r.finalB;
              final isACheaper = valA < valB;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.description, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          Text(
                            'Qty: A:${r.qtyA.toInt()} B:${r.qtyB.toInt()} | Disc: A:${r.discountA.toInt()}% B:${r.discountB.toInt()}%',
                            style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '₹${valA.toStringAsFixed(1)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isACheaper ? const Color(0xFF16A34A) : Colors.black87),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '₹${valB.toStringAsFixed(1)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: !isACheaper ? const Color(0xFF16A34A) : Colors.black87),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _comparisonRows.removeAt(idx)),
                      child: const Icon(LucideIcons.x, size: 10, color: Colors.red),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        // Inputs for new comparison
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildCompField('Item name', _compDescController),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: _buildCompField('Price A', _compValAController, isNum: true),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: _buildCompField('Price B', _compValBController, isNum: true),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                final desc = _compDescController.text.trim();
                final valA = double.tryParse(_compValAController.text);
                final valB = double.tryParse(_compValBController.text);
                final qtyA = double.tryParse(_compQtyAController.text) ?? 1.0;
                final qtyB = double.tryParse(_compQtyBController.text) ?? 1.0;
                final discA = double.tryParse(_compDiscAController.text) ?? 0.0;
                final discB = double.tryParse(_compDiscBController.text) ?? 0.0;
                if (desc.isNotEmpty && valA != null && valB != null) {
                  setState(() {
                    _comparisonRows.add(ComparisonRow(
                      description: desc,
                      valueA: valA,
                      valueB: valB,
                      qtyA: qtyA,
                      qtyB: qtyB,
                      discountA: discA,
                      discountB: discB,
                    ));
                    _compDescController.clear();
                    _compValAController.clear();
                    _compValBController.clear();
                    _compQtyAController.clear();
                    _compQtyBController.clear();
                    _compDiscAController.clear();
                    _compDiscBController.clear();
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                child: const Icon(LucideIcons.plus, size: 12, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildCompField('Qty A', _compQtyAController, isNum: true),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildCompField('Disc A %', _compDiscAController, isNum: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCompField('Qty B', _compQtyBController, isNum: true),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildCompField('Disc B %', _compDiscBController, isNum: true),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildCompField(String label, TextEditingController ctrl, {bool isNum = false}) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(fontSize: 10),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(fontSize: 8, color: Colors.grey),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
      ),
    );
  }

  Widget _buildNumPad() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      childAspectRatio: 1.8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        '↺', '⌫', '÷', '×',
        '7', '8', '9', '-',
        '4', '5', '6', '+',
        '1', '2', '3', '=',
        '0', '.', '', '',
      ].map((char) {
        if (char.isEmpty) return const SizedBox();
        return InkWell(
          onTap: () {
            if (char == '↺') {
              _clearAll();
            } else if (char == '⌫') {
              _backspace();
            } else if (['+', '-', '×', '÷'].contains(char)) {
              _setOperator(char);
            } else if (char == '=') {
              _calculate();
            } else {
              _enterDigit(char);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              char,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: ['↺', '⌫', '÷', '×', '-', '+', '='].contains(char)
                    ? AppColors.primaryGreen
                    : AppColors.darkText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
