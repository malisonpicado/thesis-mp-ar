import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:tesis_app/ui/compound/config_forms/device_name_form.dart';
import 'package:tesis_app/ui/compound/config_forms/device_net_fom.dart';
import 'package:tesis_app/ui/compound/config_forms/device_props_form.dart';
import 'package:tesis_app/ui/compound/data_validation.dart';
import 'package:tesis_app/ui/compound/select_btdevice.dart';
import 'package:tesis_app/ui/compound/turnon_bluetooth.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';
import 'package:tesis_app/utilities/form_validation.dart';
import 'package:uuid/uuid.dart';

class CreateDevice extends StatefulWidget {
  const CreateDevice({super.key});

  @override
  State<CreateDevice> createState() => _CreateDevice();
}

class _CreateDevice extends State<CreateDevice> {
  final FlutterBluetoothSerial _bluetoothSerial =
      FlutterBluetoothSerial.instance;
  int _page = -1;
  String _deviceUUID = "";
  String _deviceName = "";
  String _wifiSsid = "";
  String _wifiPassword = "";
  String _serverUrl = "";
  String _samplingTime = "";
  String _batteryMin = "0";
  String _phMin = "";
  String _phMax = "";
  String _tempMin = "";
  String _tempMax = "";
  String _tdsMin = "";
  String _tdsMax = "";
  String _ecMin = "";
  String _ecMax = "";
  String _tuMin = "";
  String _tuMax = "";
  BluetoothDevice? _bluetoothDevice;

  @override
  void initState() {
    super.initState();
    _isBluetoothEnabled();
  }

  void _isBluetoothEnabled() {
    _bluetoothSerial.isEnabled.then((value) {
      if (value == true) {
        setState(() {
          _page = 2;
        });
      } else {
        setState(() {
          _page = 1;
        });
      }
    });
  }

  void _onDeviceNameSubmit(String deviceName) {
    setState(() {
      _deviceName = deviceName;
      _deviceUUID = const Uuid().v4();
    });

    _togglePage(true);
  }

  void _onNetworkConfigSubmit(String ssid, String password, String url) {
    setState(() {
      _wifiSsid = ssid;
      _wifiPassword = password;
      _serverUrl = url;
    });

    _togglePage(true);
  }

  void _onPropsConfigSubmit(
    String samplingTime,
    String batteryMin,
    String phMin,
    String phMax,
    String tempMin,
    String tempMax,
    String tdsMin,
    String tdsMax,
    String ecMin,
    String ecMax,
    String tuMin,
    String tuMax,
  ) {
    setState(() {
      _samplingTime = samplingTime;
      // Set to: `_batteryMin = batteryMin;` if batteri is supported
      _batteryMin = "0"; 
      _phMin = phMin;
      _phMax = phMax;
      _tempMin = tempMin;
      _tempMax = tempMax;
      _tdsMin = tdsMin;
      _tdsMax = tdsMax;
      _ecMin = ecMin;
      _ecMax = ecMax;
      _tuMin = tuMin;
      _tuMax = tuMax;
    });

    _togglePage(true);
  }

  void _togglePage(bool isForward) {
    if (isForward && _page == 6) return;
    if (!isForward && _page == 1) return;

    setState(() {
      if (isForward) {
        _page++;
      } else {
        _page--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Hydric Sense"),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(AppIcons.arrow_back)),
      ),
      body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 56.0, horizontal: 16.0),
          children: [page(_page)]),
    );
  }

  Widget page(int page) {
    switch (page) {
      case -1:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case 1:
        return TurnOnBluetooth(
            onPressed: () {
              _bluetoothSerial.requestEnable().then((value) => {
                    if (value == true) {_togglePage(true)}
                  });
            },
            title: "Añade un nuevo dispositivo");
      case 2:
        return SelectBluetoothDevice(
          bluetoothSerial: _bluetoothSerial,
          onContinue: (device) {
            if (device != null) {
              setState(() {
                _bluetoothDevice = device;
              });
              _togglePage(true);
            }
          },
        );
      case 3:
        return DeviceNameForm(
          onContinue: (deviceName) {
            _onDeviceNameSubmit(deviceName);
          },
          defaultDeviceName: _deviceName,
          bluetoothName: _bluetoothDevice!.name!,
        );
      case 4:
        return DeviceNetForm(
          defaultServerUrl: _serverUrl,
          defaultWifiPassword: _wifiPassword,
          defaultWifiSsid: _wifiSsid,
          onBackward: () => {_togglePage(false)},
          onContinue: (wifiSsid, wifiPassword, serverUrl) =>
              {_onNetworkConfigSubmit(wifiSsid, wifiPassword, serverUrl)},
        );
      case 5:
        return DevicePropsForm(
          onBackward: () => {_togglePage(false)},
          onContinue: (samplingTime, batteryMin, phMin, phMax, tempMin, tempMax,
                  tdsMin, tdsMax, ecMin, ecMax, tuMin, tuMax) =>
              {
            _onPropsConfigSubmit(samplingTime, batteryMin, phMin, phMax,
                tempMin, tempMax, tdsMin, tdsMax, ecMin, ecMax, tuMin, tuMax)
          },
          defaultSamplingTime: _samplingTime,
          defaultBatteryMin: _batteryMin,
          defaultPhMin: _phMin,
          defaultPhMax: _phMax,
          defaultTempMin: _tempMin,
          defaultTempMax: _tempMax,
          defaulTtdsMin: _tdsMin,
          defaulTtdsMax: _tdsMax,
          defaultEcMin: _ecMin,
          defaultEcMax: _ecMax,
          defaultTuMin: _tuMin,
          defaultTuMax: _tuMax,
        );
      case 6:
        return DataValidation(
          isNewDevice: true,
          bluetoothDevice: _bluetoothDevice!,
          deviceData: dataToMap(
              _deviceUUID,
              _deviceName,
              _wifiSsid,
              _wifiPassword,
              _serverUrl,
              _samplingTime,
              _batteryMin,
              _phMin,
              _phMax,
              _tempMin,
              _tempMax,
              _tdsMin,
              _tdsMax,
              _ecMin,
              _ecMax,
              _tuMin,
              _tuMax,
              ),
          onSuccess: () {
            Navigator.pop(context);
          },
          onEdit: () {
            setState(() {
              _page = 4;
            });
          },
        );
      default:
        return Container();
    }
  }
}
