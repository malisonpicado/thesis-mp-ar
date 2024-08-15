import 'package:flutter/material.dart';
import 'package:tesis_app/models/parameter_type.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class CardSensorRow extends StatelessWidget {
  final bool? hasHighValue;
  final bool hasWarning;
  final ParameterType variableType;
  final double value;

  const CardSensorRow(
      {super.key,
      this.hasHighValue,
      required this.variableType,
      required this.value,
      this.hasWarning = false});

  @override
  Widget build(BuildContext context) {
    ColorScheme themeContext = Theme.of(context).colorScheme;
    Color bgColor =
        hasWarning ? themeContext.error : themeContext.tertiaryContainer;
    Color fgColor =
        hasWarning ? themeContext.onError : themeContext.onTertiaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(8), color: bgColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _getVariableIcon(fgColor),
              const SizedBox(width: 8),
              Text(
                _getVariableTitle(),
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: fgColor),
              )
            ],
          ),
          Row(
            children: [
              Text(value.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: fgColor)),
              const SizedBox(width: 4),
              if (hasHighValue != null) _getLevelIcon(fgColor)!,
            ],
          )
        ],
      ),
    );
  }

  String _getVariableTitle() {
    switch (variableType) {
      case ParameterType.ph:
        return 'pH';
      case ParameterType.temperature:
        return 'Temperatura (°C)';
      case ParameterType.electricalConductivity:
        return 'Conductividad E. (uS/cm)';
      case ParameterType.totalDissolvedSolids:
        return 'TDS (ppm)';
      case ParameterType.turbidity:
        return 'Turbidez (NTU)';
    }
  }

  Icon? _getLevelIcon(Color iconColor) {
    if (hasHighValue == null) {
      return null;
    }

    if (hasHighValue!) {
      return Icon(
        AppIcons.arrow_drop_up,
        size: 16,
        color: iconColor,
      );
    }

    return Icon(
      AppIcons.arrow_drop_down,
      size: 16,
      color: iconColor,
    );
  }

  Icon _getVariableIcon(Color iconColor) {
    switch (variableType) {
      case ParameterType.ph:
        return Icon(
          AppIcons.water_ph,
          size: 16,
          color: iconColor,
        );
      case ParameterType.temperature:
        return Icon(
          AppIcons.device_thermostat,
          size: 16,
          color: iconColor,
        );
      case ParameterType.electricalConductivity:
        return Icon(
          AppIcons.water_ec,
          size: 16,
          color: iconColor,
        );
      case ParameterType.totalDissolvedSolids:
        return Icon(
          AppIcons.total_dissolved_solids,
          size: 16,
          color: iconColor,
        );
      case ParameterType.turbidity:
        return Icon(
          Icons.water_drop_outlined,
          size: 16,
          color: iconColor,
        );
    }
  }
}
