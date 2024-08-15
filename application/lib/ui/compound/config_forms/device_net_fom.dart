import 'package:flutter/material.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class DeviceNetForm extends StatefulWidget {
  final void Function()? onBackward;
  final void Function(String wifiSsid, String wifiPassword, String serverUrl)
      onContinue;
  final String defaultWifiSsid;
  final String defaultWifiPassword;
  final String defaultServerUrl;
  final String? wifiSsidError;
  final String? wifiPasswordError;
  final String? serverUrlError;

  const DeviceNetForm(
      {super.key,
      required this.onContinue,
      required this.onBackward,
      required this.defaultServerUrl,
      required this.defaultWifiPassword,
      required this.defaultWifiSsid,
      this.wifiPasswordError,
      this.serverUrlError,
      this.wifiSsidError});

  @override
  State<DeviceNetForm> createState() {
    return _DeviceNetForm();
  }
}

class _DeviceNetForm extends State<DeviceNetForm> {
  late TextEditingController _wifiSsidController;
  late TextEditingController _wifiPasswordController;
  late TextEditingController _serverUrlController;

  @override
  void initState() {
    super.initState();
    _wifiSsidController = TextEditingController(text: widget.defaultWifiSsid);
    _wifiPasswordController =
        TextEditingController(text: widget.defaultWifiPassword);
    _serverUrlController = TextEditingController(text: widget.defaultServerUrl);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Text(
          "Configuración de red",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium!
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(
          height: 32.0,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: '¿A cuál red WiFi se conectará?',
            filled: false,
            errorText: widget.wifiSsidError,
            border: const OutlineInputBorder(),
          ),
          controller: _wifiSsidController,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(
          height: 24.0,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: '¿Cuál es la contraseña del WiFi?',
            filled: false,
            errorText: widget.wifiPasswordError,
            border: const OutlineInputBorder(),
          ),
          controller: _wifiPasswordController,
          keyboardType: TextInputType.visiblePassword,
        ),
        const SizedBox(
          height: 24.0,
        ),
        TextField(
          decoration: InputDecoration(
            labelText: 'URL del servidor',
            filled: false,
            errorText: widget.serverUrlError,
            border: const OutlineInputBorder(),
          ),
          controller: _serverUrlController,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(
          height: 32.0,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (widget.onBackward != null)
            OutlinedButton.icon(
                onPressed: widget.onBackward,
                icon: const Icon(AppIcons.arrow_back),
                label: const Text("Anterior"))
          else
            const SizedBox(),
          FilledButton.icon(
              onPressed: () => {
                    widget.onContinue(_wifiSsidController.text,
                        _wifiPasswordController.text, _serverUrlController.text)
                  },
              icon: const Icon(AppIcons.arrow_forward),
              label: const Text("Siguiente"))
        ])
      ],
    );
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _wifiPasswordController.dispose();
    _wifiSsidController.dispose();
    super.dispose();
  }
}
