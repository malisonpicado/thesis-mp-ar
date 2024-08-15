class PH {
  final double min;
  final double max;
  static const double minValue = 0;
  static const double maxValue = 14.0;

  const PH({required this.min, required this.max});
}

class Temperature {
  final double min;
  final double max;
  static const double minValue = 0.0;
  static const double maxValue = 50.0;

  const Temperature({required this.min, required this.max});
}

class TotalDissolvedSolids {
  final int min;
  final int max;
  static const int minValue = 0;
  static const int maxValue = 1000;

  const TotalDissolvedSolids({required this.min, required this.max});
}

class ElectricalConductivity {
  final double min;
  final double max;
  static const double minValue = 0;
  static const double maxValue = 670.0;

  const ElectricalConductivity({required this.min, required this.max});
}

class Turbidity {
  final double min;
  final double max;
  static const double minValue = 0;
  static const double maxValue = 3000.0;

  const Turbidity({required this.min, required this.max});
}