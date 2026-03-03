import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roi_calculator/constants/app_spacing.dart';

class BillInputSection extends StatelessWidget {
  const BillInputSection({
    super.key,
    required this.controller,
    required this.isMonthly,
    required this.onIsMonthlyChanged,
  });

  final TextEditingController controller;
  final bool isMonthly;
  final ValueChanged<bool> onIsMonthlyChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Heating/cooling bill',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: gapSmall),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller,
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
            SizedBox(width: gapTight),
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Monthly')),
                  ButtonSegment(value: false, label: Text('Annual')),
                ],
                selected: {isMonthly},
                onSelectionChanged: (Set<bool> selected) {
                  onIsMonthlyChanged(selected.first);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
