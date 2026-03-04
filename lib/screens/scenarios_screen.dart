import 'package:flutter/material.dart';
import 'package:roi_calculator/constants/app_spacing.dart';
import 'package:roi_calculator/logic/calculator_logic.dart';
import 'package:roi_calculator/models/scenario.dart';
import 'package:roi_calculator/services/scenarios_repository.dart';
import 'package:roi_calculator/utils/format_helpers.dart';

class ScenariosScreen extends StatelessWidget {
  const ScenariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ScenariosRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('My scenarios')),
      body: StreamBuilder<List<Scenario>>(
        stream: repo.watchScenarios(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(screenPadding),
                child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final scenarios = snapshot.data!;
          if (scenarios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(screenPadding),
                child: Text(
                  'No saved scenarios.\nUse Save on the calculator to add one.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(screenPadding),
            itemCount: scenarios.length,
            separatorBuilder: (_, __) => SizedBox(height: gapSmall),
            itemBuilder: (context, index) {
              final s = scenarios[index];
              final annualBill = CalculatorLogic.getAnnualBill(s.billAmount, s.isMonthly);
              final annualSavings = CalculatorLogic.getAnnualSavings(
                annualBill,
                s.windowPercent,
                s.climate,
              );
              final paybackYears = CalculatorLogic.getPaybackYears(s.projectCost, annualSavings);
              final subtitle = paybackYears != null
                  ? 'Payback: ${paybackYears.toStringAsFixed(1)} yr · ${formatCurrency(annualSavings)}/yr'
                  : '${formatCurrency(annualSavings)}/yr';
              return Card(
                child: ListTile(
                  title: Text(s.name),
                  subtitle: Text(subtitle),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, repo, s),
                    tooltip: 'Delete',
                  ),
                  onTap: () => Navigator.pop(context, s),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ScenariosRepository repo,
    Scenario scenario,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete scenario?'),
        content: Text('This will remove "${scenario.name}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await repo.deleteScenario(scenario.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Scenario deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not delete: $e')));
        }
      }
    }
  }
}
