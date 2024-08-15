import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tesis_app/models/parameter_type.dart';
import 'package:tesis_app/ui/compound/hspie_chart.dart';
import 'package:tesis_app/ui/core/device_info_row.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';
import 'package:tesis_app/utilities/statistics.dart';
import 'package:http/http.dart' as http;
import 'package:downloadsfolder/downloadsfolder.dart';

class Statistics extends StatefulWidget {
  final Map<String, dynamic> deviceInformation;
  const Statistics({super.key, required this.deviceInformation});

  @override
  State<Statistics> createState() {
    return _Statistics();
  }
}

class _Statistics extends State<Statistics> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<double> _phData = [];
  final List<double> _teData = [];
  final List<double> _tdsData = [];
  final List<double> _ecData = [];
  final List<double> _tuData = [];
  ({
    double mean,
    double min,
    double max,
    double range,
    double sdev,
    double onrange,
    double outmax,
    double outmin
  }) _statistics = (
    mean: 0.0,
    min: 0.0,
    max: 0.0,
    range: 0.0,
    sdev: 0.0,
    onrange: 0,
    outmax: 0,
    outmin: 0,
  );
  ParameterType _parameterType = ParameterType.ph;
  bool _loaded = false;
  bool _downloading = false;
  String _startDate = "";
  String _endDate = "";

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    DateTime now = DateTime.now();

    Duration oneHour = const Duration(hours: 1);
    DateTime startDate = now.subtract(oneHour);

    _db
        .collection("devices/${widget.deviceInformation['device_uuid']}/logs")
        .where("time", isGreaterThanOrEqualTo: startDate)
        .where("time", isLessThanOrEqualTo: Timestamp.now())
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          final data = docSnapshot.data();

          setState(() {
            _phData.add(double.parse(data['ph'].toString()));
            _teData.add(double.parse(data['temperature'].toString()));
            _tdsData.add(double.parse(data['tds'].toString()));
            _ecData.add(double.parse(data['conductivity'].toString()));
            _tuData.add(double.parse(data['turbidity'].toString()));
          });
        }

        _calculateStatistics(_phData, "ph");
        setState(() {
          _loaded = true;
        });
      },
    );
  }

  void _calculateStatistics(List<double> values, String property) {
    double mean = calculateMean(values);
    Map<String, double> minmax = findMinMax(values);
    double range = calculateRange(minmax['min']!, minmax['max']!);
    double standardDeviation = calculateStandardDeviation(values, mean);
    double outMax = getOutOfRangeMaxLength(
        double.parse(widget.deviceInformation['properties']['${property}_max']
            .toString()),
        values);
    double outMin = getOutOfRangeMinLength(
        double.parse(widget.deviceInformation['properties']['${property}_min']
            .toString()),
        values);
    double onrange =
        ((values.length - outMax - outMin) / values.length) * 100.0;
    double outmax = (outMax / values.length) * 100.0;
    double outmin = (outMin / values.length) * 100.0;

    setState(() {
      _statistics = (
        mean: mean,
        min: minmax['min']!,
        max: minmax['max']!,
        range: range,
        sdev: standardDeviation,
        onrange: double.parse(onrange.toStringAsFixed(2)),
        outmax: double.parse(outmax.toStringAsFixed(2)),
        outmin: double.parse(outmin.toStringAsFixed(2)),
      );
    });
  }

  Future<void> _downloadCSV() async {
    setState(() {
      _downloading = true;
    });

    // Construir la URL con los parámetros JSON
    String url = '${widget.deviceInformation['server_url']}/history';
    Map<String, String> body = {
      'device_uuid': widget.deviceInformation["device_uuid"],
      'start': _startDate,
      'end': _endDate
    };

    Uri uri = Uri.parse(url);
    var newUri = uri.replace(queryParameters: body);

    try {
      // Realizar la solicitud GET
      http.Response response = await http.get(newUri);

      // Obtener el directorio de descargas del dispositivo
      Directory? downloadsDirectory = await getExternalStorageDirectory();
      String downloadsPath = downloadsDirectory!.path;

      // Crear el archivo CSV en el directorio de descargas
      File file = File('$downloadsPath/data.csv');

      // Escribir los datos del archivo descargado
      await file.writeAsBytes(response.bodyBytes);

      String fileName =
          "${widget.deviceInformation['device_name']}_statistics.csv";

      bool? success =
          await copyFileIntoDownloadFolder("$downloadsPath/data.csv", fileName);

      setState(() {
        _downloading = false;
      });

      if (success == true) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo descargado exitosamente')),
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
      setState(() {
        _downloading = false;
      });

      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar el archivo')),
      );
    }
  }

  void _handleStartDate(String value) {
    setState(() {
      _startDate = value;
    });
  }

  void _handleEndDate(String value) {
    setState(() {
      _endDate = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceInformation['device_name']),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(AppIcons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: !_loaded
          ? const _Loader()
          : ListView(
              padding:
                  const EdgeInsets.symmetric(vertical: 56.0, horizontal: 16.0),
              children: [
                Text(
                  "Estadísticas",
                  style: theme.textTheme.displayMedium!
                      .copyWith(color: theme.colorScheme.primary),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Text(
                  "Estadísticas de los valores medidos hace 1 hora.",
                  style: theme.textTheme.bodyLarge!
                      .copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(
                  height: 32.0,
                ),
                SegmentedButton(
                  segments: const <ButtonSegment<ParameterType>>[
                    ButtonSegment<ParameterType>(
                        value: ParameterType.ph,
                        label: Text('pH'),
                        icon: Icon(AppIcons.water_ph)),
                    ButtonSegment<ParameterType>(
                        value: ParameterType.temperature,
                        label: Text('Te'),
                        icon: Icon(AppIcons.device_thermostat)),
                    ButtonSegment<ParameterType>(
                        value: ParameterType.totalDissolvedSolids,
                        label: Text('TDS'),
                        icon: Icon(AppIcons.total_dissolved_solids)),
                    ButtonSegment<ParameterType>(
                        value: ParameterType.electricalConductivity,
                        label: Text('CE'),
                        icon: Icon(AppIcons.water_ec)),
                    ButtonSegment<ParameterType>(
                        value: ParameterType.turbidity,
                        label: Text('Tu'),
                        icon: Icon(Icons.water_drop_outlined)),
                  ],
                  selected: <ParameterType>{_parameterType},
                  onSelectionChanged: (Set<ParameterType> newSelection) {
                    setState(() {
                      _parameterType = newSelection.first;
                    });
                    switch (newSelection.first) {
                      case ParameterType.ph:
                        _calculateStatistics(_phData, "ph");
                        break;
                      case ParameterType.temperature:
                        _calculateStatistics(_teData, "te");
                        break;
                      case ParameterType.totalDissolvedSolids:
                        _calculateStatistics(_tdsData, "tds");
                        break;
                      case ParameterType.electricalConductivity:
                        _calculateStatistics(_ecData, "ec");
                        break;
                      case ParameterType.turbidity:
                        _calculateStatistics(_tuData, "tu");
                        break;
                    }
                  },
                ),
                const SizedBox(height: 32.0),
                Column(
                  children: [
                    DeviceInfoRow(
                        title: "Promedio", value: _statistics.mean.toString()),
                    const SizedBox(
                      height: 4.0,
                    ),
                    DeviceInfoRow(
                        title: "Valor mínimo",
                        value: _statistics.min.toString()),
                    const SizedBox(
                      height: 4.0,
                    ),
                    DeviceInfoRow(
                        title: "Valor máximo",
                        value: _statistics.max.toString()),
                    const SizedBox(
                      height: 4.0,
                    ),
                    DeviceInfoRow(
                        title: "Rango", value: _statistics.range.toString()),
                    const SizedBox(
                      height: 4.0,
                    ),
                    DeviceInfoRow(
                        title: "Desviación estándar",
                        value: _statistics.sdev.toString()),
                  ],
                ),
                _phData.isEmpty
                    ? Column(children: [
                        const SizedBox(
                          height: 28.0,
                        ),
                        Text(
                          "Gráfica no disponible, no hay datos suficientes.",
                          style: theme.textTheme.labelLarge!
                              .copyWith(color: theme.colorScheme.error),
                        )
                      ])
                    : Column(children: [
                        const SizedBox(height: 28.0),
                        HSPieChart(
                          inRange: _statistics.onrange,
                          outMinRange: _statistics.outmin,
                          outMaxRange: _statistics.outmax,
                        )
                      ]),
                const SizedBox(height: 32.0),
                Text("Descarga los datos",
                    style: theme.textTheme.headlineSmall!
                        .copyWith(color: theme.colorScheme.onSurface)),
                const SizedBox(height: 16.0),
                Text(
                    "Descarga los datos a partir de una fecha de inicio y una fecha de cierre. Ten en cuenta que incurrirán gastos de lectura y escritura al realizar esta operación. El archivo final estará en formato csv. Formato de fecha: día-mes-año (Ej. 01-01-2024)",
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 24.0),
                Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                          labelText: 'Fecha de inicio',
                          filled: false,
                          border: OutlineInputBorder(),
                          hintText: "DD-MM-YYYY"),
                      keyboardType: TextInputType.text,
                      onChanged: _handleStartDate,
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      decoration: const InputDecoration(
                          labelText: 'Fecha final',
                          filled: false,
                          border: OutlineInputBorder(),
                          hintText: "DD-MM-YYYY"),
                      keyboardType: TextInputType.text,
                      onChanged: _handleEndDate,
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Row(
                      children: [
                        if (_downloading)
                          const CircularProgressIndicator()
                        else
                          Expanded(
                              child: FilledButton.icon(
                                  icon: const Icon(AppIcons.file_save),
                                  onPressed: _downloadCSV,
                                  label: const Text("Descargar")))
                      ],
                    )
                  ],
                )
              ],
            ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
