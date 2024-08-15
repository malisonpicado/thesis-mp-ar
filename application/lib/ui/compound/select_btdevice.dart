import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class SelectBluetoothDevice extends StatefulWidget {
  final void Function(BluetoothDevice?) onContinue;
  final FlutterBluetoothSerial bluetoothSerial;
  const SelectBluetoothDevice(
      {super.key, required this.onContinue, required this.bluetoothSerial});

  @override
  State<SelectBluetoothDevice> createState() {
    return _SelectBluetoothDevice();
  }
}

class _SelectBluetoothDevice extends State<SelectBluetoothDevice> {
  BluetoothDevice? _selectedDevice;
  List<BluetoothDevice> _listPairedDevices = [];
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _getPairedDevices();
  }

  void _setSelectedDevice(BluetoothDevice device, int index) {
    setState(() {
      _selectedDevice = device;
      _selectedIndex = index;
    });
  }

  void _getPairedDevices() {
    widget.bluetoothSerial.getBondedDevices().then((value) {
      setState(() {
        _listPairedDevices = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Añade un nuevo dispositivo",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium!
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(
          height: 32.0,
        ),
        Icon(
          AppIcons.memory,
          color: theme.colorScheme.primary,
          size: 72.0,
        ),
        const SizedBox(
          height: 32.0,
        ),
        Text(
          "Selecciona el nombre de bluetooth del dispositivo electrónico que deseas añadir:",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge!
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(
          height: 32.0,
        ),
        _PairedDevices(
            listPairedDevices: _listPairedDevices,
            selectedIndex: _selectedIndex,
            onSelect: _setSelectedDevice),
        const SizedBox(
          height: 32.0,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FilledButton.icon(
              onPressed: (_selectedDevice == null || _listPairedDevices.isEmpty)
                  ? null
                  : () {
                      widget.onContinue(_selectedDevice);
                    },
              icon: const Icon(AppIcons.arrow_forward),
              label: const Text("Continúa"))
        ]),
      ],
    );
  }
}

class _PairedDevices extends StatelessWidget {
  final List<BluetoothDevice> listPairedDevices;
  final int selectedIndex;
  final void Function(BluetoothDevice, int) onSelect;
  const _PairedDevices(
      {super.key,
      required this.listPairedDevices,
      required this.selectedIndex,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (listPairedDevices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12.0),
        color: theme.colorScheme.errorContainer,
        child: Text(
          "¡Oops! No tienes dispositivos vinculados. Ve a la configuración de bluetooth de tu teléfono y vincúlalo con el dispositivo.",
          style: theme.textTheme.bodyMedium!
              .copyWith(color: theme.colorScheme.onErrorContainer),
        ),
      );
    }

    return Column(
        children: List.generate(listPairedDevices.length, (index) {
      BluetoothDevice device = listPairedDevices[index];
      return Column(
        children: [
          ListTile(
            tileColor:
                selectedIndex == index ? theme.colorScheme.primary : null,
            title: Text(
              device.name!,
              style: TextStyle(
                color:
                    selectedIndex == index ? theme.colorScheme.onPrimary : null,
              ),
            ),
            trailing: Icon(
              Icons.arrow_right,
              color:
                  selectedIndex == index ? theme.colorScheme.onPrimary : null,
            ),
            enableFeedback: true,
            onTap: () {
              onSelect(device, index);
            },
          ),
          const Divider()
        ],
      );
    }));
  }
}
