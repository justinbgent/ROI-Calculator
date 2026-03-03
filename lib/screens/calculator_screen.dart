import 'package:flutter/material.dart';
import 'package:roi_calculator/constants/app_spacing.dart';
import 'package:roi_calculator/logic/calculator_logic.dart';
import 'package:roi_calculator/widgets/annual_savings_card.dart';
import 'package:roi_calculator/widgets/bill_input_section.dart';
import 'package:roi_calculator/widgets/climate_selector.dart';
import 'package:roi_calculator/widgets/payback_and_long_term_card.dart';
import 'package:roi_calculator/widgets/project_cost_field.dart';
import 'package:roi_calculator/widgets/window_share_slider.dart';

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
  int _yearsSlider = 10;

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
    final annualSavings = CalculatorLogic.getAnnualSavings(annualBill, _windowPercent, _climate);
    final paybackYears = CalculatorLogic.getPaybackYears(projectCost, annualSavings);
    final bottomContentPadding = screenPadding + gapLarge;

    return Scaffold(
      appBar: AppBar(title: const Text('Window Replacement ROI')),
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
