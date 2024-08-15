import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';
import 'package:tesis_app/utilities/bluetooth_data.dart';
import 'package:http/http.dart' as http;
import 'package:tesis_app/utilities/form_validation.dart';

enum _ValidationResult { success, error, loading }

class DataValidation extends StatefulWidget {
  final Map<String, dynamic> deviceData;
  final BluetoothDevice bluetoothDevice;
  final bool isNewDevice;
  final void Function()? onEdit;
  final void Function()? onSuccess;
  const DataValidation(
      {super.key,
      required this.bluetoothDevice,
      required this.deviceData,
      required this.onEdit,
      required this.onSuccess,
      required this.isNewDevice});

  @override
  State<DataValidation> createState() {
    return _DataValidation();
  }
}

class _DataValidation extends State<DataValidation> {
  _ValidationResult _dataResultState = _ValidationResult.loading;
  _ValidationResult _serverResultState = _ValidationResult.loading;
  _ValidationResult _wifiResultState = _ValidationResult.loading;
  _ValidationResult _postResultState = _ValidationResult.loading;

  @override
  void initState() {
    super.initState();
    _validate();
  }

  Future<void> _validate() async {
    await _validateData();
    await _validateServer();
    await _validateWifi();

    if (_isError()) {
      setState(() {
        _postResultState = _ValidationResult.error;
      });
    } else {
      if (widget.isNewDevice) {
        await _postNewData();
      } else {
        await _postUpdateData();
      }
    }
  }

  Future<void> _postUpdateData() async {
    Map<String, dynamic> d = widget.deviceData;
    String url = widget.deviceData['url'];

    http.Response response =
        await http.patch(Uri.parse("$url/update/${d["uuid"]}"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "network_ssid": d["ssid"],
              "sampling_time": d["sampling"],
              "battery_min": d["battery"],
              "server_url": url,
              "properties": {
                "ph_min": d["ph_min"],
                "ph_max": d["ph_max"],
                "te_min": d["te_min"],
                "te_max": d["te_max"],
                "tds_min": d["tds_min"],
                "tds_max": d["tds_max"],
                "ec_min": d["ec_min"],
                "ec_max": d["ec_max"],
                "tu_min": d["tu_min"],
                "tu_max": d["tu_max"],
              }
            }));

    if (response.statusCode == 200) {
      setState(() {
        _postResultState = _ValidationResult.success;
      });
    } else {
      setState(() {
        _postResultState = _ValidationResult.error;
      });
    }
  }

  Future<void> _postNewData() async {
    Map<String, dynamic> d = widget.deviceData;
    String url = widget.deviceData['url'];

    http.Response response = await http.post(Uri.parse("$url/new"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "device_uuid": d["uuid"],
          "device_name": d["name"],
          "bluetooth_name": widget.bluetoothDevice.name,
          "bluetooth_macaddress": widget.bluetoothDevice.address,
          "network_ssid": d["ssid"],
          "sampling_time": d["sampling"],
          "battery_min": d["battery"],
          "server_url": url,
          "properties": {
            "ph_min": d["ph_min"],
            "ph_max": d["ph_max"],
            "te_min": d["te_min"],
            "te_max": d["te_max"],
            "tds_min": d["tds_min"],
            "tds_max": d["tds_max"],
            "ec_min": d["ec_min"],
            "ec_max": d["ec_max"],
            "tu_min": d["tu_min"],
            "tu_max": d["tu_max"],
          }
        }));

    if (response.statusCode == 200) {
      setState(() {
        _postResultState = _ValidationResult.success;
      });
    } else {
      setState(() {
        _postResultState = _ValidationResult.error;
      });
    }
  }

  Future<void> _validateServer() async {
    String? url = widget.deviceData['url'];

    if (url == "" || url == null) {
      setState(() {
        _serverResultState = _ValidationResult.error;
      });
      return;
    }

    const Duration timeoutDuration = Duration(seconds: 10);
    Timer timeoutTimer = Timer(timeoutDuration, () {
      setState(() {
        _serverResultState = _ValidationResult.error;
      });
    });

    http.Response response = await http.get(Uri.parse("$url/verify"));

    timeoutTimer.cancel();

    if (response.statusCode == 200) {
      setState(() {
        _serverResultState = _ValidationResult.success;
      });
    } else {
      setState(() {
        _serverResultState = _ValidationResult.error;
      });
    }
  }

  Future<void> _validateWifi() async {
    Map<String, dynamic> d = widget.deviceData;

    bool btResponse = await sendBTDataToDevice(
        dataToCSV(
            d["uuid"],
            d["ssid"],
            d["password"],
            d["url"],
            d["sampling"],
            d["battery"],
            d["ph_min"],
            d["ph_max"],
            d["te_min"],
            d["te_max"],
            d["tds_min"],
            d["tds_max"],
            d["ec_min"],
            d["ec_max"],
            d["tu_min"],
            d["tu_max"]),
        widget.bluetoothDevice);

    if (btResponse) {
      setState(() {
        _wifiResultState = _ValidationResult.success;
      });
    } else {
      setState(() {
        _wifiResultState = _ValidationResult.error;
      });
    }
  }

  Future<void> _validateData() async {
    setState(() {
      _dataResultState = _ValidationResult.success;
    });
  }

  bool _isError() {
    return (_dataResultState == _ValidationResult.error ||
        _serverResultState == _ValidationResult.error ||
        _wifiResultState == _ValidationResult.error);
  }

  bool _isLoading() {
    return (_dataResultState == _ValidationResult.loading ||
        _serverResultState == _ValidationResult.loading ||
        _wifiResultState == _ValidationResult.loading ||
        _postResultState == _ValidationResult.loading);
  }

  Widget stateWidget(_ValidationResult result, BuildContext context) {
    switch (result) {
      case _ValidationResult.loading:
        return const CircularProgressIndicator();
      case _ValidationResult.error:
        return Icon(
          AppIcons.cancel,
          color: Theme.of(context).colorScheme.error,
        );
      case _ValidationResult.success:
        return Icon(
          AppIcons.check_circle,
          color: Colors.green.shade300,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Text(
          "Añadiendo un nuevo dispostivo",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium!
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(
          height: 32.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              AppIcons.bluetooth,
              color: theme.colorScheme.primary,
              size: 72.0,
            ),
            Icon(
              AppIcons.memory,
              color: theme.colorScheme.primary,
              size: 72.0,
            ),
          ],
        ),
        const SizedBox(
          height: 32.0,
        ),
        Column(
          children: [
            ListTile(
              trailing: stateWidget(_dataResultState, context),
              title: const Text("Validando datos"),
              enableFeedback: false,
            ),
            const Divider(),
            ListTile(
              trailing: stateWidget(_serverResultState, context),
              title: const Text("Conectando con el servidor"),
              enableFeedback: false,
            ),
            const Divider(),
            ListTile(
              trailing: stateWidget(_wifiResultState, context),
              title: const Text("Validando Red WiFi"),
              enableFeedback: false,
            ),
            const Divider(),
            ListTile(
              trailing: stateWidget(_postResultState, context),
              title: const Text("Guardando Datos"),
              enableFeedback: false,
            ),
            const Divider(),
          ],
        ),
        const SizedBox(
          height: 32.0,
        ),
        if (!_isLoading())
          _BTN(
            isError: _isError(),
            onEdit: widget.onEdit,
            onSuccess: widget.onSuccess,
          )
      ],
    );
  }
}

class _BTN extends StatelessWidget {
  final bool isError;
  final void Function()? onEdit;
  final void Function()? onSuccess;
  const _BTN(
      {required this.isError, required this.onEdit, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return Row(
        children: [
          Expanded(
              child: FilledButton.icon(
                  icon: const Icon(AppIcons.arrow_back),
                  onPressed: onEdit,
                  label: const Text("Edita las propiedades")))
        ],
      );
    }

    return Row(
      children: [
        Expanded(
            child: FilledButton(
                onPressed: onSuccess, child: const Text("¡Hecho!")))
      ],
    );
  }
}
