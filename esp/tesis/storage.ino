/**
   Enciende la señal lumínica si existe un error
   con la tarjeta SD.
*/
void sdcardLightAlert() {
  if (isSDCardEnabled) digitalWrite(SD_LED, LOW);
  else {
    digitalWrite(SD_LED, HIGH);
    initializeStorage();
  }
}

/**
   Inicializa los elementos de la sección "storage".
   Usar esta función en la función setup() o en la
   función de inicialización del dispositivo.
*/
void initializeStorage() {
  initializeSDCard();
  createDeviceFiles();
}

/**
   Inicializa la tarjeta SD en el pin [sdPin] y actualiza el estado
   de la variable global [isSDCardEnabled], FALSE si hubo un error
   y TRUE si la tarjeta SD fué inicializada correctamente.
*/
void initializeSDCard() {
  isSDCardEnabled = SD.begin(sdPin);
}

/**
   Carga en memoria los datos de configuración almacenados en la tarjeta SD,
   si hubo un error, la variable global [deviceUUID] será una cadena de
   texto vacía o no habrá ningún cambio en su valor.
*/
void loadDeviceConfiguration() {
  if (!isSDCardEnabled) return;

  String configFilePath = "/config.csv";
  String configData = "";
  File configFile;

  if (!SD.exists(configFilePath)) return;

  configFile = SD.open(configFilePath);

  if (!configFile) {
    configFile.close();
    return;
  }

  while (configFile.available()) {
    char c = configFile.read();
    configData += c;
  }

  if (configData == "") return;

  setValuesFromCSV(configData);
  deviceUUID = incomingUUID;
  incomingUUID = "";
  configFile.close();
}

/**
   Guarda los datos de configuración del dispositivo en la tarjeta
   SD. Retorna TRUE si el proceso fué exitoso, FALSE en caso contrario.
*/
bool saveDeviceConfiguration(String configurationData) {
  if (!isSDCardEnabled) return false;

  String configFilePath = "/config.csv";
  File configFile = SD.open(configFilePath, FILE_WRITE);

  if (configFile) {
    configFile.print(configurationData);
    configFile.close();
    return true;
  }

  return false;
}

/**
   Guarda los datos de los sensores y el estado en general del dispositivo
   en la tarjeta SD. Retorna TRUE si el proceso fué existoso, FALSE en
   caso contrario.
*/
bool saveDeviceData(
  bool isAlarmEnabled,
  int battery,
  bool isBluetoothEnabled,
  float conductivity,
  bool hasConnection,
  float ph,
  float tds,
  float temperature,
  float turbidity
) {
  if (!isSDCardEnabled) return false;

  String filePath = "/data_" + deviceUUID + ".csv";
  File file = SD.open(filePath, FILE_APPEND);


  if (file) {
    String data = boolToString(isAlarmEnabled) + ","
                  + battery + ","
                  + boolToString(isBluetoothEnabled) + ","
                  + conductivity + ","
                  + boolToString(hasConnection) + ","
                  + ph + ","
                  + tds + ","
                  + temperature + ","
                  + turbidity + ","
                  + rtc.getTime("%H:%M - %d/%m/%Y");
    file.println(data);
    file.close();

    return true;
  }

  return false;
}

/**
   Crea un archivo de configuración "config.csv" y un archivo de
   datos "data_[deviceUUID].csv".
*/
void createDeviceFiles() {
  if (!isSDCardEnabled) return;
  if (deviceUUID == "") return;

  String configFilePath = "/config.csv";
  String dataFilePath = "/data_" + deviceUUID + ".csv";
  File configFile;
  File dataFile;

  if (!SD.exists(configFilePath)) {
    configFile = SD.open(configFilePath, FILE_WRITE);
    if (configFile) configFile.close();
  }

  if (!SD.exists(dataFilePath)) {
    dataFile = SD.open(dataFilePath, FILE_WRITE);

    if (dataFile) {
      dataFile.println("Alarma Habilitada,Nivel de Bateria,Bluetooth Habilitado,Conductividad Electrica,Conexion,pH,Total de Solidos Disueltos,Temperatura,Turbidez,Fecha");
      dataFile.close();
    }
  }
}
