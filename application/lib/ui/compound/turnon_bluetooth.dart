import 'package:flutter/material.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class TurnOnBluetooth extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  const TurnOnBluetooth(
      {super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium!
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(
          height: 32.0,
        ),
        Icon(
          AppIcons.bluetooth,
          color: theme.colorScheme.primary,
          size: 72.0,
        ),
        const SizedBox(
          height: 32.0,
        ),
        Text(
          "Para continuar, debes de tener activado el bluetooth de tu dispositivo móvil y el bluetooth del dispositivo de medición.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!
              .copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(
          height: 16.0,
        ),
        Text(
          "¿Deseas activar el bluetooth de este teléfono?",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(
          height: 32.0,
        ),
        Row(
          children: [
            Expanded(
                child: FilledButton(
                    onPressed: onPressed,
                    child: const Text("Activa el bluetooth")))
          ],
        )
      ],
    );
  }
}
