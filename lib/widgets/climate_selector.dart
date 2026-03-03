import 'package:flutter/material.dart';
import 'package:roi_calculator/constants/app_spacing.dart';
import 'package:roi_calculator/logic/calculator_logic.dart';

class ClimateSelector extends StatelessWidget {
  const ClimateSelector({super.key, required this.value, required this.onChanged});

  final Climate value;
  final ValueChanged<Climate> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Climate / region', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: gapSmall),
        SegmentedButton<Climate>(
          segments: const [
            ButtonSegment(value: Climate.cold, label: Text('Cold')),
            ButtonSegment(value: Climate.moderate, label: Text('Moderate')),
            ButtonSegment(value: Climate.hot, label: Text('Hot')),
          ],
          selected: {value},
          onSelectionChanged: (Set<Climate> selected) {
            onChanged(selected.first);
          },
        ),
      ],
    );
  }
}
