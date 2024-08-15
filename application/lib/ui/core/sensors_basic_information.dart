import 'package:flutter/material.dart';

class SensorsBasicInformation extends StatelessWidget {
  final String title;
  final String value;
  final IconData informationIcon;

  const SensorsBasicInformation(
      {super.key,
      required this.title,
      required this.value,
      required this.informationIcon});

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                Theme.of(context).textTheme.bodyLarge!.copyWith(color: color)),
        Row(
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: color)),
            const SizedBox(width: 8, height: 8),
            Icon(informationIcon, color: color, size: 20)
          ],
        )
      ],
    );
  }
}
