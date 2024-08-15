import 'package:flutter/material.dart';

/// [AppPopupItem] is the widget that goes inside [PopupMenuItem]
/// in order to meet Material 3 standard.
class AppPopupItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const AppPopupItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24.0,
          color: theme.colorScheme.onSurface,
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          text,
          style: theme.textTheme.bodyLarge!
              .copyWith(color: theme.colorScheme.onSurface),
        )
      ],
    );
  }
}