import 'package:tesis_app/models/parameters.dart';

enum Fish {
  tilapia(
      ph: PH(min: 6.0, max: 9.0),
      temperature: Temperature(min: 28.0, max: 32.0),
      tds: TotalDissolvedSolids(min: 150, max: 300),
      ec: ElectricalConductivity(min: 235.0, max: 468.0),
      tu: Turbidity(min: 1, max: 400)),
  guapote(
      ph: PH(min: 7.0, max: 9.0),
      temperature: Temperature(min: 22.0, max: 27.0),
      tds: TotalDissolvedSolids(min: 230, max: 340),
      ec: ElectricalConductivity(min: 360.0, max: 531.0),
      tu: Turbidity(min: 1, max: 500)),
  mojarra(
      ph: PH(min: 6.8, max: 7.2),
      temperature: Temperature(min: 23.0, max: 30.0),
      tds: TotalDissolvedSolids(min: 150, max: 300),
      ec: ElectricalConductivity(min: 235.0, max: 468.0),
      tu: Turbidity(min: 1, max: 500));

  const Fish(
      {required this.ph,
      required this.temperature,
      required this.tds,
      required this.ec,
      required this.tu});

  final PH ph;
  final Temperature temperature;
  final TotalDissolvedSolids tds;
  final ElectricalConductivity ec;
  final Turbidity tu;
}
