import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/models/parameter_type.dart';
import 'package:tesis_app/ui/compound/bluetooth_dialog.dart';
import 'package:tesis_app/ui/core/property_chip.dart';
import 'package:tesis_app/ui/core/row_action.dart';
import 'package:tesis_app/ui/core/sensors_basic_information.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';
import 'package:tesis_app/ui/logic/logic.dart';
import 'package:tesis_app/utilities/compare_values.dart';
import 'package:tesis_app/utilities/date.dart';

class RealtimeSection extends StatefulWidget {
  final Map<String, dynamic> deviceInformation;
  const RealtimeSection({super.key, required this.deviceInformation});

  @override
  State<RealtimeSection> createState() => _RealtimeSection();
}

class _RealtimeSection extends State<RealtimeSection> {
  bool _isBluetoothOn = false;
  bool _isAlarmOn = false;
  // int _batteryLevel = 0;
  bool _isDeviceConnected = false;
  String _lastUpdate = "";
  double _ph = 0.0;
  double _te = 0.0;
  double _tds = 0.0;
  double _ec = 0.0;
  double _tu = 0.0;
  // (inrange, ismax)
  (bool, bool) _phRange = (true, false);
  (bool, bool) _teRange = (true, false);
  (bool, bool) _tdsRange = (true, false);
  (bool, bool) _ecRange = (true, false);
  (bool, bool) _tuRange = (true, false);
  late DatabaseReference ref;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  void _updateData() {
    ref = FirebaseDatabase.instance
        .ref('devices/${widget.deviceInformation['device_uuid']}');
    ref.onValue.listen((DatabaseEvent event) {
      final snap = event.snapshot;
      Map<dynamic, dynamic> values = snap.value as Map;

      setState(() {
        _isBluetoothOn = values['bluetooth_enabled'];
        _isAlarmOn = values['alarm_enabled'];
        // _batteryLevel = values['battery_level'];
        _isDeviceConnected = values['connection'];
        _lastUpdate = fromIsoToDateFormatted(values['time']);
        _ph = double.parse(values['ph'].toString());
        _te = double.parse(values['temperature'].toString());
        _tds = double.parse(values['tds'].toString());
        _ec = double.parse(values['conductivity'].toString());
        _tu = double.parse(values['turbidity'].toString());

        _phRange = compareValue(
            value: _ph,
            limitMin: double.parse(
                widget.deviceInformation['properties']['ph_min'].toString()),
            limitMax: double.parse(
                widget.deviceInformation['properties']['ph_max'].toString()));
        _teRange = compareValue(
            value: _te,
            limitMin: double.parse(
                widget.deviceInformation['properties']['te_min'].toString()),
            limitMax: double.parse(
                widget.deviceInformation['properties']['te_max'].toString()));
        _tdsRange = compareValue(
            value: _tds,
            limitMin: double.parse(
                widget.deviceInformation['properties']['tds_min'].toString()),
            limitMax: double.parse(
                widget.deviceInformation['properties']['tds_max'].toString()));
        _ecRange = compareValue(
            value: _ec,
            limitMin: double.parse(
                widget.deviceInformation['properties']['ec_min'].toString()),
            limitMax: double.parse(
                widget.deviceInformation['properties']['ec_max'].toString()));
        _tuRange = compareValue(
            value: _tu,
            limitMin: double.parse(
                widget.deviceInformation['properties']['tu_min'].toString()),
            limitMax: double.parse(
                widget.deviceInformation['properties']['tu_max'].toString()));
      });
    });
  }

  void _handleBluetoothSwitch(bool value) {
    ref.update({
      "bluetooth_enabled": value,
    });
  }

  void _handleAlarmSwitch(bool value) {
    ref.update({
      "alarm_enabled": value,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RowAction(
          title: "Acidez (pH)",
          actionWidget: PropertyChip(
              value: _ph.toString(),
              parameterType: ParameterType.ph,
              outOfRange: !_phRange.$1),
        ),
        const SizedBox(
          height: 16.0,
        ),
        RowAction(
          title: "Temperatura",
          supportText: "Unidad: grados celcius (°C)",
          actionWidget: PropertyChip(
              value: _te.toString(),
              parameterType: ParameterType.temperature,
              outOfRange: !_teRange.$1),
        ),
        const SizedBox(
          height: 16.0,
        ),
        RowAction(
          title: "Total de Sólidos Disueltos",
          supportText: "Unidad: partes por millon (ppm)",
          actionWidget: PropertyChip(
              value: _tds.toString(),
              parameterType: ParameterType.totalDissolvedSolids,
              outOfRange: !_tdsRange.$1),
        ),
        const SizedBox(
          height: 16.0,
        ),
        RowAction(
          title: "Conductividad Eléctrica",
          supportText: "Unidad: microsiemens por cm (uS/cm)",
          actionWidget: PropertyChip(
              value: _ec.toString(),
              parameterType: ParameterType.electricalConductivity,
              outOfRange: !_ecRange.$1),
        ),
        const SizedBox(
          height: 16.0,
        ),
        RowAction(
          title: "Turbidez",
          supportText: "Unidad: NTU",
          actionWidget: PropertyChip(
              value: _tu.toString(),
              parameterType: ParameterType.turbidity,
              outOfRange: !_tuRange.$1),
        ),
        const SizedBox(
          height: 28.0,
        ),
        RowAction(
            title: "Bluetooth",
            supportText:
                "${_isBluetoothOn ? "Desactiva" : "Activa"} el bluetooth de este dispositivo",
            actionWidget: Switch(
                value: _isBluetoothOn,
                onChanged: (value) {
                  if (value) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return BluetoothDialog(
                            value: value,
                            onAccept: _handleBluetoothSwitch,
                          );
                        });
                  } else {
                    _handleBluetoothSwitch(value);
                  }
                })),
        const SizedBox(
          height: 16.0,
        ),
        RowAction(
            title: "Alarma",
            supportText:
                "${_isAlarmOn ? "Desactiva" : "Activa"} la alarma de este dispositivo",
            actionWidget: Switch(
                value: _isAlarmOn,
                onChanged: (value) {
                  _handleAlarmSwitch(value);
                })),
        const SizedBox(
          height: 28.0,
        ),
        SensorsBasicInformation(
            title: 'Última medición',
            value: _lastUpdate,
            informationIcon: AppIcons.schedule),
        const SizedBox(
          height: 8.0,
        ),
        // SensorsBasicInformation(
        //     title: 'Nivel de batería',
        //     value: "${_batteryLevel.toString()}%",
        //     informationIcon: getBatteryIcon(_batteryLevel)),
        // const SizedBox(
        //   height: 8.0,
        // ),
        SensorsBasicInformation(
            title: 'Conexión',
            value: _isDeviceConnected ? "Sí" : "No",
            informationIcon: getConnectionIcon(_isDeviceConnected)),
        const SizedBox(
          height: 24.0,
        ),
      ],
    );
  }
}
