import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final String title;
  const SectionDivider({super.key, this.title = ""});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(title,
            style: theme.textTheme.labelSmall!
                .copyWith(color: theme.colorScheme.onSurfaceVariant))
      ],
    );
  }
}
