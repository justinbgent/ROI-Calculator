import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roi_calculator/logic/calculator_logic.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _billController = TextEditingController();
  final _projectCostController = TextEditingController();

  bool _isMonthly = true;
  double _windowPercent = 15;
  Climate _climate = Climate.moderate;
  int _yearsSlider = 10; // 1–30 for long-term savings view

  static String _formatCurrency(double value) {
    if (value.isNaN || value.isInfinite) return r'$0';
    final int v = value.round();
    final s = v.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${v < 0 ? '-' : ''}\$$buf';
  }

  @override
  void initState() {
    super.initState();
    _billController.addListener(_onInputChanged);
    _projectCostController.addListener(_onInputChanged);
  }

  void _onInputChanged() => setState(() {});

  @override
  void dispose() {
    _billController.removeListener(_onInputChanged);
    _projectCostController.removeListener(_onInputChanged);
    _billController.dispose();
    _projectCostController.dispose();
    super.dispose();
  }

  double _parseDouble(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final billAmount = _parseDouble(_billController.text);
    final projectCost = _parseDouble(_projectCostController.text);
    final annualBill = CalculatorLogic.getAnnualBill(billAmount, _isMonthly);
    final annualSavings = CalculatorLogic.getAnnualSavings(
      annualBill,
      _windowPercent,
      _climate,
    );
    final paybackYears = CalculatorLogic.getPaybackYears(
      projectCost,
      annualSavings,
    );

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      appBar: AppBar(title: const Text('Window Replacement ROI')),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill amount + Monthly/Annual
            Text(
              'Heating/cooling bill',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _billController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      hintText: '0',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Monthly')),
                      ButtonSegment(value: false, label: Text('Annual')),
                    ],
                    selected: {_isMonthly},
                    onSelectionChanged: (Set<bool> selected) {
                      setState(() => _isMonthly = selected.first);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Window % slider
            Text(
              'Bill from windows: ${_windowPercent.round()}%',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: _windowPercent,
              min: 5,
              max: 50,
              divisions: 45,
              label: '${_windowPercent.round()}%',
              onChanged: (value) => setState(() => _windowPercent = value),
            ),
            const SizedBox(height: 16),

            // Project cost
            TextField(
              controller: _projectCostController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'One-time project cost',
                border: OutlineInputBorder(),
                hintText: '0',
              ),
            ),
            const SizedBox(height: 24),

            // Climate
            Text(
              'Climate / region',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<Climate>(
              segments: const [
                ButtonSegment(value: Climate.cold, label: Text('Cold')),
                ButtonSegment(value: Climate.moderate, label: Text('Moderate')),
                ButtonSegment(value: Climate.hot, label: Text('Hot')),
              ],
              selected: {_climate},
              onSelectionChanged: (Set<Climate> selected) {
                setState(() => _climate = selected.first);
              },
            ),
            const SizedBox(height: 32),

            // Result card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated annual savings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(annualSavings),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    if (annualSavings > 0 && paybackYears != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Payback: ~${paybackYears.toStringAsFixed(1)} years',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            /// Bottom section "Payback"
            const SizedBox(height: 32),

            // Payback & long-term savings section
            Text(
              'Payback & long-term savings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (annualSavings > 0 && paybackYears != null) ...[
                      Text(
                        'Payback in ${paybackYears.toStringAsFixed(1)} years.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total savings by year $_yearsSlider: ${_formatCurrency(annualSavings * _yearsSlider)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _yearsSlider.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '$_yearsSlider years',
                        onChanged: (value) =>
                            setState(() => _yearsSlider = value.round()),
                      ),
                      if (_yearsSlider >= paybackYears)
                        Text(
                          'Project cost covered by year ${paybackYears.ceil()}.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ] else ...[
                      Text(
                        'Payback: —',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter bill, project cost, and window % to see payback and total savings.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Based on typical efficiency gains from new windows.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
