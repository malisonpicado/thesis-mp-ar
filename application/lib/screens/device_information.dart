import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/screens/config_device.dart';
import 'package:tesis_app/screens/statistics.dart';
import 'package:tesis_app/ui/compound/delete_dialog.dart';
import 'package:tesis_app/ui/compound/realtime_section.dart';
import 'package:tesis_app/ui/core/device_info_row.dart';
import 'package:tesis_app/ui/core/section_divider.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';
import 'package:tesis_app/utilities/date.dart';

class DeviceInformation extends StatelessWidget {
  final Map<String, dynamic> deviceInformation;
  const DeviceInformation({super.key, required this.deviceInformation});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Timestamp dbdate = deviceInformation['created_date'] as Timestamp;
    DateTime date = Timestamp(dbdate.seconds, dbdate.nanoseconds).toDate();
    String createdDate = fromIsoToDateFormatted(date.toIso8601String());

    return Scaffold(
      appBar: AppBar(
        title: Text(deviceInformation['device_name']),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(AppIcons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 56.0, horizontal: 16.0),
        children: [
          Text(
            deviceInformation['device_name'],
            style: theme.textTheme.displayMedium!
                .copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(
            height: 32.0,
          ),
          const SectionDivider(
            title: "Monitoreo en tiempo real",
          ),
          const SizedBox(
            height: 28.0,
          ),
          RealtimeSection(deviceInformation: deviceInformation),
          Row(children: [
            Expanded(
                child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Statistics(
                                  deviceInformation: deviceInformation)));
                    },
                    icon: const Icon(AppIcons.arrow_forward),
                    label: const Text("Ver Estadísticas")))
          ]),
          const SizedBox(
            height: 32.0,
          ),
          const SectionDivider(
            title: "Configuración del dispositivo",
          ),
          const SizedBox(
            height: 28.0,
          ),
          Column(
            children: [
              DeviceInfoRow(
                  title: "Nombre del dispositivo",
                  value: deviceInformation['device_name']),
              const SizedBox(
                height: 4.0,
              ),
              DeviceInfoRow(
                  title: "Nombre de bluetooth",
                  value: deviceInformation['bluetooth_name']),
              const SizedBox(
                height: 4.0,
              ),
              DeviceInfoRow(
                  title: "Red WiFi", value: deviceInformation['network_ssid']),
              const SizedBox(
                height: 4.0,
              ),
              DeviceInfoRow(
                  title: "Tiempo de muestreo",
                  value: "${deviceInformation['sampling_time']} minutos"),
              const SizedBox(
                height: 4.0,
              ),
              DeviceInfoRow(title: "Fecha de creación", value: createdDate),
              const SizedBox(
                height: 4.0,
              ),
              DeviceInfoRow(
                  title: "Rango de pH",
                  value:
                      "${deviceInformation['properties']['ph_min']} - ${deviceInformation['properties']['ph_max']}"),
              const SizedBox(
                height: 4.0,
              ),
              DeviceInfoRow(
                  title: "Rango de temperatura",
                  value:
                      "${deviceInformation['properties']['te_min']} - ${deviceInformation['properties']['te_max']}"),
              const SizedBox(
                height: 4.0,
              ),
              DeviceInfoRow(
                  title: "Rango de TDS",
                  value:
                      "${deviceInformation['properties']['tds_min']} - ${deviceInformation['properties']['tds_max']}"),
              const SizedBox(
                height: 4.0,
              ),
              DeviceInfoRow(
                  title: "Rango de Cond. Eléc.",
                  value:
                      "${deviceInformation['properties']['ec_min']} - ${deviceInformation['properties']['ec_max']}"),
              const SizedBox(
                height: 4.0,
              ),
              DeviceInfoRow(
                  title: "Rango de Turbidez",
                  value:
                      "${deviceInformation['properties']['tu_min']} - ${deviceInformation['properties']['tu_max']}"),
              const SizedBox(
                height: 24.0,
              ),
              Row(
                children: [
                  Expanded(
                      child: FilledButton.icon(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConfigureDevice(
                                          deviceInformation: deviceInformation,
                                        )));
                          },
                          label: const Text("Configura este dispositivo")))
                ],
              ),
              const SizedBox(
                height: 8.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return DeleteDialog(
                                deviceUUID: deviceInformation['device_uuid'],
                              );
                            });
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text("Elimina este dispositivo"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error, //<-- SEE HERE
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
