import 'package:flutter/material.dart';
import 'package:roi_calculator/constants/app_spacing.dart';
import 'package:roi_calculator/logic/calculator_logic.dart';
import 'package:roi_calculator/models/scenario.dart';
import 'package:roi_calculator/screens/scenarios_screen.dart';
import 'package:roi_calculator/services/scenarios_repository.dart';
import 'package:roi_calculator/widgets/annual_savings_card.dart';
import 'package:roi_calculator/widgets/bill_input_section.dart';
import 'package:roi_calculator/widgets/climate_selector.dart';
import 'package:roi_calculator/widgets/payback_and_long_term_card.dart';
import 'package:roi_calculator/widgets/project_cost_field.dart';
import 'package:roi_calculator/widgets/window_share_slider.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key, this.initialScenario});

  final Scenario? initialScenario;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _billController = TextEditingController();
  final _projectCostController = TextEditingController();
  final _scenariosRepo = ScenariosRepository();

  bool _isMonthly = true;
  double _windowPercent = 15;
  Climate _climate = Climate.moderate;
  int _yearsSlider = 10;

  @override
  void initState() {
    super.initState();
    _billController.addListener(_onInputChanged);
    _projectCostController.addListener(_onInputChanged);
    // Load initial scenario if passed in, otherwise defaults will load.
    final initial = widget.initialScenario;
    if (initial != null) {
      _loadScenario(initial);
    }
  }

  void _loadScenario(Scenario s) {
    _billController.text = s.billAmount > 0 ? s.billAmount.toString() : '';
    _projectCostController.text = s.projectCost > 0 ? s.projectCost.toString() : '';
    setState(() {
      _isMonthly = s.isMonthly;
      _windowPercent = s.windowPercent;
      _climate = s.climate;
      _yearsSlider = s.yearsSlider;
    });
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

  Future<void> _openScenarios() async {
    final scenario = await Navigator.push<Scenario?>(
      context,
      MaterialPageRoute(builder: (context) => const ScenariosScreen()),
    );
    if (scenario != null && mounted) {
      _loadScenario(scenario);
    }
  }

  Future<void> _showSaveDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _SaveScenarioDialog(),
    );
    if (name == null || !mounted) return;
    final billAmount = _parseDouble(_billController.text);
    final projectCost = _parseDouble(_projectCostController.text);
    try {
      await _scenariosRepo.addScenario(
        name: name,
        billAmount: billAmount,
        isMonthly: _isMonthly,
        windowPercent: _windowPercent,
        projectCost: projectCost,
        climate: _climate,
        yearsSlider: _yearsSlider,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved "$name"')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final billAmount = _parseDouble(_billController.text);
    final projectCost = _parseDouble(_projectCostController.text);
    final annualBill = CalculatorLogic.getAnnualBill(billAmount, _isMonthly);
    final annualSavings = CalculatorLogic.getAnnualSavings(annualBill, _windowPercent, _climate);
    final paybackYears = CalculatorLogic.getPaybackYears(projectCost, annualSavings);
    final bottomContentPadding = screenPadding + gapLarge;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Window Replacement ROI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _openScenarios,
            tooltip: 'My scenarios',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _showSaveDialog,
            tooltip: 'Save scenario',
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(screenPadding).copyWith(bottom: bottomContentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BillInputSection(
                  controller: _billController,
                  isMonthly: _isMonthly,
                  onIsMonthlyChanged: (value) => setState(() => _isMonthly = value),
                ),
                SizedBox(height: gapLarge),
                WindowShareSlider(
                  value: _windowPercent,
                  onChanged: (value) => setState(() => _windowPercent = value),
                ),
                SizedBox(height: gapMedium),
                ProjectCostField(controller: _projectCostController),
                SizedBox(height: gapLarge),
                ClimateSelector(
                  value: _climate,
                  onChanged: (value) => setState(() => _climate = value),
                ),
                SizedBox(height: gapXLarge),
                AnnualSavingsCard(annualSavings: annualSavings, paybackYears: paybackYears),
                SizedBox(height: gapXLarge),
                PaybackAndLongTermCard(
                  annualSavings: annualSavings,
                  paybackYears: paybackYears,
                  yearsSlider: _yearsSlider,
                  onYearsSliderChanged: (value) => setState(() => _yearsSlider = value),
                ),
                SizedBox(height: gapLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveScenarioDialog extends StatefulWidget {
  const _SaveScenarioDialog();

  @override
  State<_SaveScenarioDialog> createState() => _SaveScenarioDialogState();
}

class _SaveScenarioDialogState extends State<_SaveScenarioDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save scenario'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Home 2024'),
        autofocus: true,
        onSubmitted: (value) => Navigator.pop(context, value.trim().isEmpty ? null : value.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            Navigator.pop(context, name.isEmpty ? null : name);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
