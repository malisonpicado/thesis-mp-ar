/// Compara si el valor de la propiedad está dentro del rango permitido.
/// Retorna (true, _) si el valor está dentro del rango permitido.
/// Retorna (_, true) si el valor está por encima del límite máximo, de lo contrario
/// está por debajo del límite inferior
/// Ignorar el segundo valor si el primero es verdadero
///
(bool inrange, bool ismax) compareValue(
    {required double value,
    required double limitMin,
    required double limitMax}) {
  return ((value > limitMin && value < limitMax), (value >= limitMax));
}
