/**
   Enciende la señal lumínica si existe un error
   con la conexión WiFi.
*/
void wifiLighAlert() {
  if (WiFi.status() == WL_CONNECTED) digitalWrite(WIFI_LED, LOW);
  else digitalWrite(WIFI_LED, HIGH);
}

/**
   Activa el bluetooth del dispositivo y actualiza el estado
   de la variable global [isBTEnabled]. FALSE si hubo un error,
   TRUE si el bluetooth fué activado exitosamente.
*/
void enableBluetooth() {
  if (isBTEnabled) return;

  WiFi.disconnect();
  isBTEnabled = SerialBT.begin("ESP32_Bluetooth");
  if (isBTEnabled) digitalWrite(BT_LED, HIGH);
  isBTEnabled = true;
}

/**
   Desactiva el bluetooth del dispositivo y actualiza el estado
   de la variable global [isBTEnabled] a FALSE.
*/
void disableBluetooth() {
  if (!isBTEnabled) return;

  SerialBT.disconnect();
  SerialBT.end();
  isBTEnabled = false;
  digitalWrite(BT_LED, LOW);
}

/**
   Recibe y procesa los datos de configuración enviados
   por el dispositivo móvil. Responde '1' si la configuración
   fué establecida correctamente, '0' en caso contrario.
*/
void readIncomingBluetoothData() {
  if (!SerialBT.available()) return;

  String data = SerialBT.readStringUntil('\n');
  setValuesFromCSV(data);

  /**
     Si la UUID actual es distinta de la UUID enviada,
     no se establece la configuración.
  */
  if (deviceUUID != "" && incomingUUID != deviceUUID) {
    SerialBT.write('0');
    return;
  }

  if (!initializeWiFi()) {
    SerialBT.write('0');
    resetConfigValues();
    return;
  }

  deviceUUID = incomingUUID;
  incomingUUID = "";
  elapsedTime = 60 * samplingTime;
  createDeviceFiles();
  saveDeviceConfiguration(data);
  SerialBT.write('1');
  disableBluetooth();
}

/**
   Intenta conectarse a la red WiFi con las credenciales de las
   variables globales [ssid] y [password]. Realiza hasta 20
   intentos de conexión.
*/
bool initializeWiFi() {
  int currentAttempts = 0;

  if (WiFi.status() == WL_CONNECTED) WiFi.disconnect();

  do {
    if (currentAttempts == 20) break;

    WiFi.begin(ssid, password);

    while (WiFi.status() == WL_DISCONNECTED) delay(200);

    currentAttempts++;

    if (WiFi.status() == WL_NO_SSID_AVAIL) break;
  } while (WiFi.status() != WL_CONNECTED);

  return WiFi.status() == WL_CONNECTED;
}

/**
   Envía a través del protocolo HTTP la información general del
   dispositivo y los datos obtenidos de los sensores, usando
   el método POST y enviándolo a la dirección de enlace almacenada
   en la variable global [serverUrl] y la ruta "/data". El cuerpo
   de la petición está en formato JSON. Si existe un error en la
   transmisión la información la guardará localmente.
*/
void sendPostData(
  float ph,
  float temperature,
  float tds,
  float conductivity,
  float turbidity,
  int batteryLevel,
  bool isAlarmEnabled,
  bool isBluetoothEnabled,
  bool phNotInRange,
  bool teNotInRange,
  bool tdsNotInRange,
  bool ecNotInRange,
  bool tuNotInRange
) {
  HTTPClient http;
  String serverPath = serverUrl + "/data";

  http.begin(serverPath.c_str());
  http.addHeader("Content-Type", "application/json");

  String requestBody = "{"
                       "\"device_uuid\": \""
                       + deviceUUID + "\","
                       "\"battery_level\": "
                       + batteryLevel + ","
                       "\"connection\": true,"
                       "\"ph\": "
                       + ph + ","
                       "\"conductivity\": "
                       + conductivity + ","
                       "\"temperature\": "
                       + temperature + ","
                       "\"tds\": "
                       + tds + ","
                       "\"turbidity\": "
                       + turbidity + ","
                       "\"bluetooth_enabled\": "
                       + boolToString(isBluetoothEnabled) + ","
                       "\"critical_props\": \""
                       + criticalProps(phNotInRange, teNotInRange, tdsNotInRange, ecNotInRange, tuNotInRange) + "\","
                       "\"alarm_enabled\": "
                       + boolToString(isAlarmEnabled) + "}";

  int statusCode = http.POST(requestBody);

  if (statusCode != 200) {
    saveDeviceData(isAlarmEnabled, batteryLevel, isBluetoothEnabled, conductivity, false, ph, tds, temperature, turbidity);
  }

  http.end();
}

/**
   Realiza una petición HTTP a la dirección de enlace almacenada en la
   variable global [serverUrl]. La petición es de tipo GET y la envía
   a la ruta "/btalarm", con el parámetro de consulta "device_uuid" y el
   valor de la variable global [deviceUUID]. Consulta las preferencias
   del usuario, si el bluetooth/alarma deben de estar activas o desactivadas.

   Retorna la respuesta del servidor en formato CSV o una cadena de texto
   vacía si hubo un error durante la petición.
*/
String getUserAction() {
  if (WiFi.status() != WL_CONNECTED) return "";

  HTTPClient http;
  String serverPath = serverUrl + "/btalarm?device_uuid=" + deviceUUID;
  String serverResponse = "";

  http.begin(serverPath.c_str());

  int responseCode = http.GET();

  if (responseCode == 200)
    serverResponse = http.getString();

  http.end();

  return serverResponse;
}

/**
   Realiza una petición al servidor para obtener la hora y fecha

   Retorna una cadena de texto con el formato:
    hora,minutos,segundos,dia,mes,año (HH,mm,SS,DD,MM,YYYY)
   Retorna "" si hubo algún error.
*/
String fetchTime() {
  if (WiFi.status() != WL_CONNECTED) return "";

  HTTPClient http;
  String serverPath = serverUrl + "/time";
  String serverResponse = "";

  http.begin(serverPath.c_str());

  int responseCode = http.GET();

  if (responseCode == 200)
    serverResponse = http.getString();

  http.end();

  return serverResponse;
}
