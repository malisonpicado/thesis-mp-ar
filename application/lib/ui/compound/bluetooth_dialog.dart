import 'package:flutter/material.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class BluetoothDialog extends StatelessWidget {
  final void Function(bool) onAccept;
  final bool value;
  const BluetoothDialog(
      {super.key, required this.onAccept, required this.value});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
      title: const Text('¿Desea activar el bluetooth de este dispositivo?'),
      content: const Text(
          'Activar el bluetooth de este dispositivo detendrá todos los procesos en curso. La única manera de reanudar estos procesos es configurando nuevamente el dispositivo a través de bluetooth, por lo cual la activación debe ser realizada con precaución.'),
      actions: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(AppIcons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
                label: const Text("Cancela"),
              ),
            ),
            const SizedBox(
              width: 16.0,
            ),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(AppIcons.bluetooth),
                onPressed: () {
                  onAccept(value);
                  Navigator.pop(context);
                },
                label: const Text('Procede'),
              ),
            )
          ],
        ),
      ],
    );
  }
}
