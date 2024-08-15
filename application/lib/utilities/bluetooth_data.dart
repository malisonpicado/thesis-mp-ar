import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

Future<bool> sendBTDataToDevice(
    String deviceData, BluetoothDevice btDevice) async {
  Completer<bool> completer =
      Completer<bool>(); // Completer para manejar la respuesta

  BluetoothConnection connection =
      await BluetoothConnection.toAddress(btDevice.address);

  connection.output.add(textoAUint8List("$deviceData\n"));

  connection.input!.listen((Uint8List data) {
    String incomingData = ascii.decode(data);

    bool response = incomingData == "1"; // Determinar la respuesta

    connection.finish();

    completer.complete(response); // Completar el Completer con la respuesta
  });

  return completer.future;
}

Uint8List textoAUint8List(String texto) {
  List<int> bytes =
      utf8.encode(texto); // Convierte el texto a una lista de bytes UTF-8
  return Uint8List.fromList(bytes);
}
