import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class DeviceNameForm extends StatefulWidget {
  final void Function(String deviceName) onContinue;
  final String bluetoothName;
  final String defaultDeviceName;
  final String? errorText;

  const DeviceNameForm(
      {super.key,
      required this.onContinue,
      required this.defaultDeviceName,
      required this.bluetoothName,
      this.errorText});

  @override
  State<DeviceNameForm> createState() {
    return _DeviceNameForm();
  }
}

class _DeviceNameForm extends State<DeviceNameForm> {
  late TextEditingController _deviceNameController;

  @override
  void initState() {
    super.initState();
    _deviceNameController =
        TextEditingController(text: widget.defaultDeviceName);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Text(
          "¡Configúralo!",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium!
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(
          height: 32.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Creando configuración para: ${widget.bluetoothName}",
                softWrap: true,
                textAlign: TextAlign.left,
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: theme.colorScheme.onSurfaceVariant))
          ],
        ),
        const SizedBox(
          height: 32.0,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: "¿Qué nombre tendrá el dispositivo?",
            filled: false,
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
          ),
          controller: _deviceNameController,
          keyboardType: TextInputType.text,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          maxLength: 20,
        ),
        const SizedBox(
          height: 32.0,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FilledButton.icon(
              onPressed: () => {widget.onContinue(_deviceNameController.text)},
              icon: const Icon(AppIcons.arrow_forward),
              label: const Text("Siguiente")),
        ]),
      ],
    );
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    super.dispose();
  }
}
