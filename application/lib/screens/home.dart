import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/screens/create_device.dart';
import 'package:tesis_app/ui/compound/manual_popup_menu.dart';
import 'package:tesis_app/ui/compound/realtime_panel.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() {
    return _Home();
  }
}

class _Home extends State<Home> {
  Widget _pageWidget = const _Loader();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _devices = [];

  @override
  void initState() {
    super.initState();
    _getDevices();
  }

  void _getDevices() {
    final docRef = db.collection('devices');

    docRef.get().then((value) {
      if (value.docs.isEmpty) {
        _updatePageWidget(const _NoDevices());
      } else {
        List<Map<String, dynamic>> values = [];
        for (var data in value.docs) {
          values.add(data.data());
        }
        setState(() {
          _devices = values;
          _updatePageWidget(DevicesList(
            listOfDevices: _devices,
          ));
        });
      }
    });
  }

  void _updatePageWidget(Widget bodyWidget) {
    setState(() {
      _pageWidget = bodyWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Hydric Sense",
        ),
        actions: <Widget>[
          ManualPopupMenu(
              serverUrl:
                  _devices.isNotEmpty ? _devices.first['server_url'] : "")
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const CreateDevice()));
          },
          tooltip: "Añadir un nuevo dispositivo",
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: const Icon(AppIcons.add)),
      body: _pageWidget,
    );
  }
}

class _NoDevices extends StatelessWidget {
  const _NoDevices({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "¡Oops! Parece que aún no has agregado ningún dispositivo de monitoreo. Añade un nuevo dispositivo haciendo click en el botón de la parte de abajo.",
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium!
                .copyWith(color: theme.colorScheme.primary),
          ),
        ));
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

class DevicesList extends StatelessWidget {
  final List<Map<String, dynamic>> listOfDevices;
  const DevicesList({super.key, required this.listOfDevices});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 56.0, horizontal: 16.0),
      children: listOfDevices
          .map((device) => Column(
                children: [
                  RealtimePanel(deviceInformation: device),
                  const SizedBox(
                    height: 28.0,
                  )
                ],
              ))
          .toList(),
    );
  }
}
