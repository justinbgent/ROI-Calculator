import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProjectCostField extends StatelessWidget {
  const ProjectCostField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      decoration: const InputDecoration(
        labelText: 'One-time project cost',
        border: OutlineInputBorder(),
        hintText: '0',
        prefixText: r'$ ',
      ),
    );
  }
}
