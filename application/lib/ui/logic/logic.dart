import 'package:flutter/material.dart';
import 'package:tesis_app/ui/icons/app_icons.dart';

IconData getBatteryIcon(int batteryLevel) {
  if (batteryLevel > 75) return AppIcons.battery_full_alt;
  if (batteryLevel > 50) return AppIcons.battery_horiz_075;
  if (batteryLevel > 25) return AppIcons.battery_horiz_050;
  if (batteryLevel > 10) return AppIcons.battery_low;

  return AppIcons.battery_horiz_000;
}

IconData getConnectionIcon(bool isConnected) {
  if (isConnected) return AppIcons.sensors;

  return AppIcons.signal_disconnected;
}
