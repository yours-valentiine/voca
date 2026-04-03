import 'package:flutter/material.dart';

class MaterialSwitch extends StatelessWidget {
  const MaterialSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return const Icon(Icons.check);
        }
        return null;
      }),
      onChanged: onChanged,
    );
  }
}
