import 'package:flutter/material.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class NotificationDialog extends StatelessWidget {
  final String deviceName;
  final String emergencyProps;
  const NotificationDialog(
      {super.key, required this.deviceName, required this.emergencyProps});

  @override
  Widget build(BuildContext context) {
    bool hasEmergencyProps = emergencyProps != "";

    return AlertDialog(
      icon: Icon(
        hasEmergencyProps
            ? Icons.warning_rounded
            : AppIcons.signal_disconnected,
        color: Theme.of(context).colorScheme.error,
        size: 48.0,
      ),
      title: Text(
          hasEmergencyProps
              ? "Emergencia en $deviceName"
              : "$deviceName está desconectado",
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Theme.of(context).colorScheme.error)),
      content: Text(
        hasEmergencyProps
            ? 'Se ha detectado una emergencia en el dispositivo $deviceName. Las siguientes variables están fuera de su rango permitido: ${_listToText(emergencyProps.toString().split(","))}. Toma medidas inmediatas para garantizar la calidad del agua del estanque.'
            : "Se ha detectado una desconexión del dispositivo $deviceName. Por favor, verifique la conexión a internet del dispositivo.",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        Row(children: [
          Expanded(
              child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Entendido"),
          ))
        ])
      ],
    );
  }

  String _propertyCodeToText(String code) {
    switch (code) {
      case "ph":
        return "pH";
      case "te":
        return "Temperatura";
      case "tds":
        return "TDS";
      case "ec":
        return "Conductividad Eléctrica";
      case "tu":
        return "Turbidez";
      default:
        return "";
    }
  }

  String _listToText(List<String> props) {
    String txt = "";

    for (String prop in props) {
      txt += ", ";
      txt += _propertyCodeToText(prop);
    }

    return txt.replaceFirst(", ", "");
  }
}
