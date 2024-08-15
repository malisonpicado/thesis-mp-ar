import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/screens/home.dart';
import 'package:tesis_app/ui/color_schemes.dart';
import 'package:tesis_app/ui/compound/notification_dialog.dart';
import 'package:tesis_app/ui/text_schemes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  if (Platform.isIOS || Platform.isMacOS) {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
  }

  final apnsToken = await FirebaseMessaging.instance.getToken();
  if (apnsToken != null) {
    _postNewData(apnsToken);
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (navigatorKey.currentContext != null) {
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) {
            return NotificationDialog(
              deviceName: message.data['device_name'],
              emergencyProps: message.data['props'] ?? "",
            );
          });
    }
  });

  runApp(const MyApp());
}

/// COMPLETAR CON LA URL DEL SERVIDOR
Future<void> _postNewData(String token) async {
  String url = ""; // ESTABLECER URL DEL SERVIDOR

  http.Response response = await http.post(Uri.parse("$url/notify"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "user_id": token,
      }));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          textTheme: appTextScheme),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          textTheme: appTextScheme),
      home: const Home(),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
