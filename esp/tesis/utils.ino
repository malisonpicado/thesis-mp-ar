/**
   Toma las variables que están fuera de rango y
   retorna una cadena de texto con el acrónimo
   de las propiedades, separadas por "|".

   Ejemplo:
   Si las variables ph, temperatura y turbidez están
   fuera de rango, entonces el valor de los parámetros
   son: criticalProps(true, true, false, false, true); y
   retorna: "ph|te|tu"
*/
String criticalProps(bool ph, bool te, bool tds, bool ec, bool tu) {
  String result = "";

  if (ph) result += "ph|";
  if (te) result += "te|";
  if (tds)  result += "tds|";
  if (ec)  result += "ec|";
  if (tu)  result += "tu|";

  if (result != "") result.remove(result.length() - 1);

  return result;
}

/**
   Retorna una representación textual de un valor
   booleano.
*/
String boolToString(bool value) {
  if (value == true) return "true";

  return "false";
}

/**
  Añade a una lista de enteros [result] los valores de la hora
  y fecha, basado en el formato:  hora,minutos,segundos,dia,mes,año
  (HH,mm,SS,DD,MM,YYYY) de la cadena de texto [str]
*/
void timeParser(String str, int result[]) {
  int index = 0;
  int start = 0;
  int end = str.indexOf(',');

  while (end != -1 && index < 6) {
    result[index++] = str.substring(start, end).toInt();
    start = end + 1;
    end = str.indexOf(',', start);
  }

  // Añadir el último valor después de la última coma
  if (index < 6) {
    result[index] = str.substring(start).toInt();
  }
}

/**
   Evalúa si una propiedad físico-química está fuera del
   rango de valores permitidos.
*/
bool isPropertyOutOfRange(float actualValue, float valueMin, float valueMax) {
  return (actualValue <= valueMin || actualValue >= valueMax);
}

/**
   Convierte el resultado de la función [getUserAction] y asigna
   a las variables globales [isAlEnabled] y [isBTEnabled] el valor
   booleano correspondiente.

   Ejemplo:
   "true,false" -> [isAlEnabled] = true, [isBTEnabled] = false
*/
void setBtalarm(String response) {
  int startIndex = 0;
  int endIndex = response.indexOf(',');

  isAlEnabled = response.substring(startIndex, endIndex) == "true";
  startIndex = endIndex + 1;
  bool bluetooth = response.substring(startIndex) == "true";

  if (bluetooth) enableBluetooth();
  else disableBluetooth();
}

/**
   Convierte los datos (en formato .csv) de configuración provenientes
   del dispositivo móvil del usuario y los asigna a su variable
   global correspondiente.
*/
void setValuesFromCSV(String csvData) {
  int startIndex = 0;
  int endIndex = csvData.indexOf(',');

  incomingUUID = csvData.substring(startIndex, endIndex);
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);

  // Cancela la operación si la UUID recibida es diferente de la UUID actual
  if (deviceUUID != "" && incomingUUID != deviceUUID) return;

  ssid = csvData.substring(startIndex, endIndex);
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  password = csvData.substring(startIndex, endIndex);
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  serverUrl = csvData.substring(startIndex, endIndex);
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  samplingTime = csvData.substring(startIndex, endIndex).toInt();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  batteryMin = csvData.substring(startIndex, endIndex).toInt();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  PH_min = csvData.substring(startIndex, endIndex).toFloat();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  PH_max = csvData.substring(startIndex, endIndex).toFloat();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  TEMP_min = csvData.substring(startIndex, endIndex).toFloat();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  TEMP_max = csvData.substring(startIndex, endIndex).toFloat();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  TDS_min = csvData.substring(startIndex, endIndex).toFloat();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  TDS_max = csvData.substring(startIndex, endIndex).toFloat();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  EC_min = csvData.substring(startIndex, endIndex).toFloat();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  EC_max = csvData.substring(startIndex, endIndex).toFloat();
  startIndex = endIndex + 1;
  endIndex = csvData.indexOf(',', startIndex);
  TU_min = csvData.substring(startIndex, endIndex).toFloat();
  startIndex = endIndex + 1;
  TU_max = csvData.substring(startIndex).toFloat();
}

/**
   Establece a los valores por defecto la configuración
   del dispositivo.
*/
void resetConfigValues() {
  incomingUUID = "";
  deviceUUID = "";
  ssid = "";
  password = "";
  serverUrl = "";
  samplingTime = 0;
  batteryMin = 0;
  PH_min = 0.0;
  PH_max = 0.0;
  TEMP_min = 0.0;
  TEMP_max = 0.0;
  TDS_min = 0.0;
  TDS_max = 0.0;
  EC_min = 0.0;
  EC_max = 0.0;
  TU_min = 0.0;
  TU_max = 0.0;
}

/**
   ============================================================
   NOTA: Si el dispositivo de monitoreo trabaja con batería,
   hacer uso de las siguiente funciones. El servidor y el
   código fuente de la aplicación, tienen soporte para esta
   característica.
   ============================================================
*/

int getBatteryLevel(int pin) {
  return voltageToPercentage((analogRead(pin) / 4095.0) * 3.3);
}

int voltageToPercentage(float voltage) {
  float voltagePoints[] = {2.60, 2.7281, 2.7682, 2.8485, 2.8886, 2.9287, 2.9688, 3.3};
  int percentagePoints[] = {1, 5, 15, 25, 50, 75, 95, 100};

  if (voltage <= voltagePoints[0]) return percentagePoints[0];
  if (voltage >= voltagePoints[7]) return percentagePoints[7];

  for (int i = 0; i < 7; i++) {
    if (voltage >= voltagePoints[i] && voltage <= voltagePoints[i + 1]) {
      float rangeVoltage = voltagePoints[i + 1] - voltagePoints[i];
      int rangePercentage = percentagePoints[i + 1] - percentagePoints[i];
      float scale = (voltage - voltagePoints[i]) / rangeVoltage;
      return percentagePoints[i] + (scale * rangePercentage);
    }
  }

  return 0;
}
