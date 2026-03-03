import 'package:flutter/material.dart';
import 'package:roi_calculator/constants/app_spacing.dart';
import 'package:roi_calculator/utils/format_helpers.dart';

class PaybackAndLongTermCard extends StatelessWidget {
  const PaybackAndLongTermCard({
    super.key,
    required this.annualSavings,
    this.paybackYears,
    required this.yearsSlider,
    required this.onYearsSliderChanged,
  });

  final double annualSavings;
  final double? paybackYears;
  final int yearsSlider;
  final ValueChanged<int> onYearsSliderChanged;

  @override
  Widget build(BuildContext context) {
    final hasValidPayback = annualSavings > 0 && paybackYears != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Payback & long-term savings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: gapTight),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasValidPayback) ...[
                  Text(
                    'Payback in ${paybackYears!.toStringAsFixed(1)} years.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: gapMedium),
                  Text(
                    'Total savings by year $yearsSlider: ${formatCurrency(annualSavings * yearsSlider)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  SizedBox(height: gapSmall),
                  Slider(
                    value: yearsSlider.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: '$yearsSlider years',
                    onChanged: (value) =>
                        onYearsSliderChanged(value.round()),
                  ),
                  if (yearsSlider >= paybackYears!)
                    Text(
                      'Project cost covered by year ${paybackYears!.ceil()}.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ] else ...[
                  Text(
                    'Payback: —',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: gapSmall),
                  Text(
                    'Enter bill, project cost, and window % to see payback and total savings.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                SizedBox(height: gapMedium),
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
      ],
    );
  }
}
