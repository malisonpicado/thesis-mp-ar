import 'dart:math';

/// Verifica si el valor de una propiedad físico-química medida por el sensor
/// está dentro del rango de valores permitido. El rango de valores permitido
/// es el rango en la cual, el valor de la propiedad físico-química no causaría
/// ningún daño para el pez.
///
/// NOTA: si el campo `isInRange` es `true`, ignorar el campo `isValueHigh`,
/// de lo contrario el campo `isValueHigh` indica si está por encima del límite
/// máximo (`true`) o por debajo del límite mínimo (`false`).
///
/// @param value Valor actual de la propiedad físico-química
/// @param min Límite crítico mínimo
/// @param max Límite crítico máximo
/// @returns Si el valor está dentro del rango permitido y si el valor está por encima o debajo de los límites.
Map<String, bool> isValueInRange(double value, double min, double max) {
  final isInRange = value < max && value > min;
  return {'isInRange': isInRange, 'isValueHigh': value >= max};
}

/// Calcula la media estadística de los valores obtenidos por los sensores.
///
/// @param list Lista de valores.
/// @returns Promedio | media.
double calculateMean(List<double> list) {
  if (list.isEmpty) {
    return 0;
  }

  final sum = list.reduce((acc, value) => acc + value);
  final average = sum / list.length;
  return double.parse(average.toStringAsFixed(2));
}

/// Retorna el valor mínimo y el valor máximo de una lista de valores
/// obtenidos por los sensores.
///
/// @param arr Valores.
/// @returns Valor mínimo y máximo.
Map<String, double> findMinMax(List<double> arr) {
  if (arr.isEmpty) {
    return {"min": 0, "max": 0};
  }

  final min = arr.reduce((value, element) => value < element ? value : element);
  final max = arr.reduce((value, element) => value > element ? value : element);

  return {'min': min, 'max': max};
}

/// Calcula el rango estadístico de dos valores.
///
/// NOTA: obtener el valor máximo y mínimo de una lista de valores usando
/// la función `findMinMax([...])`
///
/// @param min El valor mínimo obtenido por los sensores
/// @param max El valor máximo obtenido por los sensores
/// @returns Rango estadístico.
double calculateRange(double min, double max) {
  return double.parse((max - min).toStringAsFixed(2));
}

/// Calcula la desviación estándar de la lista de valores obtenidos por los sensores.
///
/// NOTA: obtener la media estadística o promedio usando la funcion `calculateMean([...])`
///
/// @param list Valores.
/// @param mean Media estadística de los valores.
/// @returns Desviación estándar.
double calculateStandardDeviation(List<double> list, double mean) {
  if (list.isEmpty) {
    return 0;
  }

  double squaredDeviations = list.fold(0, (acc, value) {
    double difference = value - mean;
    return acc + pow(difference, 2);
  });

  final variance = squaredDeviations / list.length;
  final standardDeviation = sqrt(variance);

  return double.parse(standardDeviation.toStringAsFixed(2));
}

double getOutOfRangeMaxLength(double limit, List<double> data) {
  int length = 0;

  for (double value in data) {
    if (value >= limit) length++;
  }

  return length.toDouble();
}

double getOutOfRangeMinLength(double limit, List<double> data) {
  int length = 0;

  for (double value in data) {
    if (value <= limit) length++;
  }

  return length.toDouble();
}
