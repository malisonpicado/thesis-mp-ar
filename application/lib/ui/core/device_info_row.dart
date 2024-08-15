import 'package:flutter/material.dart';

class DeviceInfoRow extends StatelessWidget {
  final String title;
  final String value;

  const DeviceInfoRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          softWrap: true,
          textAlign: TextAlign.left,
          style: theme.textTheme.labelLarge!
              .copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(
          width: 16.0,
        ),
        Text(
          value,
          softWrap: true,
          textAlign: TextAlign.left,
          style: theme.textTheme.bodySmall!
              .copyWith(color: theme.colorScheme.secondary),
        ),
      ],
    );
  }
}
