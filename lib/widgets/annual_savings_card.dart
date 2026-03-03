import 'package:flutter/material.dart';
import 'package:roi_calculator/constants/app_spacing.dart';
import 'package:roi_calculator/utils/format_helpers.dart';

class AnnualSavingsCard extends StatelessWidget {
  const AnnualSavingsCard({super.key, required this.annualSavings, this.paybackYears});

  final double annualSavings;
  final double? paybackYears;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estimated annual savings', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: gapSmall),
            Text(
              formatCurrency(annualSavings),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            if (annualSavings > 0 && paybackYears != null) ...[
              SizedBox(height: gapMedium),
              Text(
                'Payback: ~${paybackYears!.toStringAsFixed(1)} years',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
