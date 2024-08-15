import 'package:flutter/material.dart';
import 'package:tesis_app/screens/home.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';
import 'package:http/http.dart' as http;

class DeleteDialog extends StatefulWidget {
  final String deviceUUID;
  const DeleteDialog({super.key, required this.deviceUUID});

  @override
  State<DeleteDialog> createState() {
    return _DeleteDialog();
  }
}

class _DeleteDialog extends State<DeleteDialog> {
  String _serverUrl = "";

  Future<http.Response> _deleteDevice() async {
    String url = _serverUrl;

    http.Response response =
        await http.delete(Uri.parse("$url/delete/${widget.deviceUUID}"));

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Quieres eliminar este dispositivo?'),
      content: const Text(
          'Esta decisión no se puede deshacer. Se eliminaran todos los datos de este dispositivo, incluyendo los datos de las mediciones. Asegúrate de haber guardado todos los datos.'),
      actions: [
        TextField(
          decoration: const InputDecoration(
            labelText: "Escribe la url del servidor",
            filled: false,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          onChanged: (value) {
            setState(() {
              _serverUrl = value;
            });
          },
        ),
        const SizedBox(
          height: 32.0,
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(AppIcons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
                label: const Text("Cancelar"),
              ),
            ),
            const SizedBox(
              width: 16.0,
            ),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.delete_outline_rounded),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.error),
                ),
                onPressed: () {
                  _deleteDevice().then((value) {
                    if (value.statusCode == 200) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    }
                  });
                },
                label: const Text('Elimínalo'),
              ),
            )
          ],
        ),
      ],
    );
  }
}
