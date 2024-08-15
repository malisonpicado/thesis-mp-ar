import 'dart:io';

import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';
import 'package:tesis_app/ui/core/app_popup_item.dart';
import 'package:http/http.dart' as http;

class ManualPopupMenu extends StatelessWidget {
  final String serverUrl;
  const ManualPopupMenu({super.key, required this.serverUrl});

  Future<void> _downloadManual(BuildContext context) async {
    if (serverUrl == "") return;

    String url = '$serverUrl/manual';
    Uri uri = Uri.parse(url);

    try {
      // Realizar la solicitud GET
      http.Response response = await http.get(uri);

      // Obtener el directorio de descargas del dispositivo
      Directory? downloadsDirectory = await getExternalStorageDirectory();
      String downloadsPath = downloadsDirectory!.path;

      // Crear el archivo CSV en el directorio de descargas
      File file = File('$downloadsPath/manual.pdf');

      // Escribir los datos del archivo descargado
      await file.writeAsBytes(response.bodyBytes);

      String fileName = "manual.pdf";

      bool? success = await copyFileIntoDownloadFolder(
          "$downloadsPath/manual.pdf", fileName);

      if (success == true) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Manual descargado exitosamente')),
        );
      } else {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Archivo guardado internamente. No se pudo acceder a la carpeta de descargas')),
        );
      }
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el archivo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        icon: const Icon(Icons.help_outline),
        itemBuilder: (context) => [
              PopupMenuItem(
                child: const AppPopupItem(
                  icon: AppIcons.file_save,
                  text: "Descarga el Manual",
                ),
                onTap: () {
                  _downloadManual(context);
                },
              ),
            ]);
  }
}
