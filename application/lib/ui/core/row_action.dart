import 'package:flutter/material.dart';

class RowAction extends StatelessWidget {
  final String title;
  final String? supportText;
  final Widget actionWidget;
  const RowAction(
      {super.key,
      required this.title,
      this.supportText,
      required this.actionWidget});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              softWrap: true,
              style: theme.textTheme.bodyLarge!
                  .copyWith(color: theme.colorScheme.onSurface),
            ),
            if (supportText != null)
              Text(
                supportText!,
                softWrap: true,
                style: theme.textTheme.bodySmall!
                    .copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(width: 16.0),
        actionWidget,
      ],
    );
  }
}
