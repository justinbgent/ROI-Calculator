import 'package:flutter/material.dart';
import 'package:roi_calculator/constants/app_spacing.dart';
import 'package:roi_calculator/utils/format_helpers.dart';

class PaybackAndLongTermCard extends StatefulWidget {
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
  State<PaybackAndLongTermCard> createState() => _PaybackAndLongTermCardState();
}

class _PaybackAndLongTermCardState extends State<PaybackAndLongTermCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasValidPayback = widget.annualSavings > 0 && widget.paybackYears != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaybackHeader(
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? _PaybackContent(
                  hasValidPayback: hasValidPayback,
                  annualSavings: widget.annualSavings,
                  paybackYears: widget.paybackYears,
                  yearsSlider: widget.yearsSlider,
                  onYearsSliderChanged: widget.onYearsSliderChanged,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _PaybackHeader extends StatelessWidget {
  const _PaybackHeader({
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Payback & long-term savings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaybackContent extends StatelessWidget {
  const _PaybackContent({
    required this.hasValidPayback,
    required this.annualSavings,
    required this.paybackYears,
    required this.yearsSlider,
    required this.onYearsSliderChanged,
  });

  final bool hasValidPayback;
  final double annualSavings;
  final double? paybackYears;
  final int yearsSlider;
  final ValueChanged<int> onYearsSliderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
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
                    onChanged: (value) => onYearsSliderChanged(value.round()),
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
