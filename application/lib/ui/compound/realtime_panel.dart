import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/models/parameter_type.dart';
import 'package:tesis_app/screens/device_information.dart';
import 'package:tesis_app/ui/core/card_sensor_row.dart';
import 'package:tesis_app/ui/core/sensors_basic_information.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';
import 'package:tesis_app/ui/logic/logic.dart';
import 'package:tesis_app/utilities/compare_values.dart';
import 'package:tesis_app/utilities/date.dart';

class RealtimePanel extends StatefulWidget {
  final Map<String, dynamic> deviceInformation;
  const RealtimePanel({super.key, required this.deviceInformation});

  @override
  State<RealtimePanel> createState() => _RealtimePanel();
}

class _RealtimePanel extends State<RealtimePanel> {
  // int _batteryLevel = 0;
  bool _isDeviceConnected = false;
  String _lastUpdate = "";
  String _deviceName = "";
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
        // _batteryLevel = values['battery_level'];
        _isDeviceConnected = values['connection'];
        _lastUpdate = fromIsoToDateFormatted(values['time']);
        _ph = double.parse(values['ph'].toString());
        _te = double.parse(values['temperature'].toString());
        _tds = double.parse(values['tds'].toString());
        _ec = double.parse(values['conductivity'].toString());
        _tu = double.parse(values['turbidity'].toString());
        _deviceName = widget.deviceInformation['device_name'] as String;

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

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        color: theme.colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _deviceName,
                style: theme.textTheme.displayMedium!
                    .copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(
                height: 32.0,
              ),
              Column(
                children: [
                  CardSensorRow(
                      variableType: ParameterType.ph,
                      value: _ph,
                      hasWarning: !_phRange.$1,
                      hasHighValue: _phRange.$1 ? null : _phRange.$2),
                  const SizedBox(
                    height: 4.0,
                  ),
                  CardSensorRow(
                      variableType: ParameterType.temperature,
                      value: _te,
                      hasWarning: !_teRange.$1,
                      hasHighValue: _teRange.$1 ? null : _teRange.$2),
                  const SizedBox(
                    height: 4.0,
                  ),
                  CardSensorRow(
                      variableType: ParameterType.totalDissolvedSolids,
                      value: _tds,
                      hasWarning: !_tdsRange.$1,
                      hasHighValue: _tdsRange.$1 ? null : _tdsRange.$2),
                  const SizedBox(
                    height: 4.0,
                  ),
                  CardSensorRow(
                      variableType: ParameterType.electricalConductivity,
                      value: _ec,
                      hasWarning: !_ecRange.$1,
                      hasHighValue: _ecRange.$1 ? null : _ecRange.$2),
                  const SizedBox(
                    height: 4.0,
                  ),
                  CardSensorRow(
                      variableType: ParameterType.turbidity,
                      value: _tu,
                      hasWarning: !_tuRange.$1,
                      hasHighValue: _tuRange.$1 ? null : _tuRange.$2),
                ],
              ),
              const SizedBox(
                height: 24.0,
              ),
              const Divider(),
              const SizedBox(
                height: 24.0,
              ),
              Column(
                children: [
                  SensorsBasicInformation(
                      title: 'Última medición',
                      value: _lastUpdate,
                      informationIcon: AppIcons.schedule),
                  const SizedBox(
                    height: 4.0,
                  ),
                  // SensorsBasicInformation(
                  //     title: 'Nivel de batería',
                  //     value: "$_batteryLevel%",
                  //     informationIcon: getBatteryIcon(_batteryLevel)),
                  // const SizedBox(
                  //   height: 4.0,
                  // ),
                  SensorsBasicInformation(
                      title: 'Conexión',
                      value: _isDeviceConnected ? "Sí" : "No",
                      informationIcon: getConnectionIcon(_isDeviceConnected)),
                ],
              ),
              const SizedBox(height: 32.0),
              Row(
                children: [
                  Expanded(
                      child: FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DeviceInformation(
                                      deviceInformation:
                                          widget.deviceInformation)),
                            );
                          },
                          child: const Text("Más información")))
                ],
              )
            ],
          ),
        ));
  }
}
