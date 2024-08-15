import 'package:tesis_app/models/parameters.dart';
import 'package:tesis_app/models/parameter_type.dart';

enum RangeType { min, max }

void validateDeviceName(String deviceName) {
  String formattedName = deviceName.replaceAll(' ', '');

  RegExp regExp = RegExp(r'^[a-zA-Z0-9_]+$');
  if (!regExp.hasMatch(formattedName)) {
    throw 'El nombre solo debe de contener letras y números';
  }
}

void compare(String min, String max) {
  double pMin = double.parse(min);
  double pMax = double.parse(max);

  if (pMin > pMax || pMin == pMax) {
    throw 'El valor mínimo del parámetro no debe ser mayor o igual al valor máximo';
  }
}

void validateParameterValue(
    ParameterType parameterType, RangeType range, double value) {
  if (range == RangeType.min) {
    switch (parameterType) {
      case ParameterType.ph:
        if (value < PH.minValue) {
          throw 'El valor mínimo no puede ser menor a ${PH.minValue}';
        }
        break;
      case ParameterType.temperature:
        if (value < Temperature.minValue) {
          throw 'El valor mínimo no puede ser menor a ${Temperature.minValue}';
        }
        break;
      case ParameterType.totalDissolvedSolids:
        if (value < Temperature.minValue) {
          throw 'El valor mínimo no puede ser menor a ${TotalDissolvedSolids.minValue}';
        }
        break;
      case ParameterType.electricalConductivity:
        if (value < Temperature.minValue) {
          throw 'El valor mínimo no puede ser menor a ${ElectricalConductivity.minValue}';
        }
        break;
      case ParameterType.turbidity:
        if (value < Turbidity.minValue) {
          throw 'El valor mínimo no puede ser menor a ${Turbidity.minValue}';
        }
        break;
    }
  }

  switch (parameterType) {
    case ParameterType.ph:
      if (value < PH.minValue) {
        throw 'El valor máximo no puede ser menor a ${PH.maxValue}';
      }
      break;
    case ParameterType.temperature:
      if (value < Temperature.minValue) {
        throw 'El valor máximo no puede ser menor a ${Temperature.maxValue}';
      }
      break;
    case ParameterType.totalDissolvedSolids:
      if (value < Temperature.minValue) {
        throw 'El valor máximo no puede ser menor a ${TotalDissolvedSolids.maxValue}';
      }
      break;
    case ParameterType.electricalConductivity:
      if (value < Temperature.minValue) {
        throw 'El valor máximo no puede ser menor a ${ElectricalConductivity.maxValue}';
      }
      break;
    case ParameterType.turbidity:
      if (value < Turbidity.minValue) {
        throw 'El valor máximo no puede ser menor a ${Turbidity.maxValue}';
      }
      break;
  }
}

void noNegativeMinutes(String minutes) {
  if (int.parse(minutes) < 0) {
    throw 'Números negativos no son aceptados';
  }
}

// uuid,ssid,password,url,sampling,battery,ph_min,ph_max,te_min,te_max,tds_min,tds_max,ec_min,ec_max
String dataToCSV(
    String uuid,
    String ssid,
    String password,
    String url,
    String sampling,
    String battery,
    String phMin,
    String phMax,
    String teMin,
    String teMax,
    String tdsMin,
    String tdsMax,
    String ecMin,
    String ecMax,
    String tuMin,
    String tuMax) {
  return "$uuid,$ssid,$password,$url,$sampling,$battery,$phMin,$phMax,$teMin,$teMax,$tdsMin,$tdsMax,$ecMin,$ecMax,$tuMin,$tuMax";
}

Map<String, dynamic> dataToMap(
    String uuid,
    String name,
    String ssid,
    String password,
    String url,
    String sampling,
    String battery,
    String phMin,
    String phMax,
    String teMin,
    String teMax,
    String tdsMin,
    String tdsMax,
    String ecMin,
    String ecMax,
    String tuMin,
    String tuMax) {
  return {
    "uuid": uuid,
    "name": name,
    "ssid": ssid,
    "password": password,
    "url": url,
    "sampling": sampling,
    "battery": battery,
    "ph_min": phMin,
    "ph_max": phMax,
    "te_min": teMin,
    "te_max": teMax,
    "tds_min": tdsMin,
    "tds_max": tdsMax,
    "ec_min": ecMin,
    "ec_max": ecMax,
    "tu_min": tuMin,
    "tu_max": tuMax
  };
}
