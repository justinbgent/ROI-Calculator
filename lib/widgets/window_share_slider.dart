import 'package:flutter/material.dart';

class WindowShareSlider extends StatelessWidget {
  const WindowShareSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Bill from windows: ${value.round()}%',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          value: value,
          min: 5,
          max: 50,
          divisions: 45,
          label: '${value.round()}%',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
