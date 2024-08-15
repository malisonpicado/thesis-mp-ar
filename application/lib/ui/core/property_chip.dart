import 'package:flutter/material.dart';
import 'package:tesis_app/models/parameter_type.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class PropertyChip extends StatelessWidget {
  final String value;
  final bool outOfRange;
  final ParameterType parameterType;

  const PropertyChip(
      {super.key,
      required this.value,
      required this.parameterType,
      this.outOfRange = false});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    ThemeData theme = Theme.of(context);

    switch (parameterType) {
      case ParameterType.ph:
        icon = AppIcons.water_ph;
      case ParameterType.electricalConductivity:
        icon = AppIcons.water_ec;
      case ParameterType.totalDissolvedSolids:
        icon = AppIcons.total_dissolved_solids;
      case ParameterType.temperature:
        icon = AppIcons.device_thermostat;
      case ParameterType.turbidity:
        icon = Icons.water_drop_outlined;
    }

    return Container(
      decoration: BoxDecoration(
          color: (outOfRange)
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.surface,
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(8.0))),
      padding: const EdgeInsets.fromLTRB(8.0, 6.0, 16.0, 6.0),
      child: IntrinsicWidth(
        child: Row(children: [
          Icon(icon,
              size: 18.0,
              color: (outOfRange)
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSurface),
          const SizedBox(
            width: 8.0,
          ),
          Text(
            value,
            style: theme.textTheme.labelLarge!.copyWith(
                color: (outOfRange)
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onSurface),
          )
        ]),
      ),
    );
  }
}
