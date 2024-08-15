/**
   Toma medida de las propiedades físico-químicas del agua
   y las envía al servidor o las guarda localmente en caso
   de fallo en la conexión WiFi.
*/
void measure() {
  if (deviceUUID == "" || isBTEnabled || (elapsedTime < 60 * samplingTime)) return;

  float ph = readPh();
  float temperature = readTemperature();

  digitalWrite(tdsPositive, HIGH);
  delay(200);

  float tds = readTDS(temperature);
  float conductivity = readConductivity(tds);
  float turbidity = readTurbidity();
  int batteryLevel = 0;

  bool tempOut = isPropertyOutOfRange(temperature, TEMP_min, TEMP_max);
  bool tdsOut = isPropertyOutOfRange(tds, TDS_min, TDS_max);
  bool phOut = isPropertyOutOfRange(ph, PH_min, PH_max);
  bool ecOut = isPropertyOutOfRange(conductivity, EC_min, EC_max);
  bool tuOut = isPropertyOutOfRange(turbidity, TU_min, TU_max);
  isAlEnabled = tempOut || tdsOut || phOut || ecOut || tuOut;

  digitalWrite(tdsPositive, LOW);

  if (WiFi.status() != WL_CONNECTED) {
    saveDeviceData(isAlEnabled, batteryLevel, isBTEnabled, conductivity, false, ph, tds, temperature, turbidity);
    elapsedTime = 0;
    initializeWiFi();
    return;
  }

  if (isSDCardEnabled)
    sendPostData(ph, temperature, tds, conductivity, turbidity, batteryLevel, isAlEnabled, isBTEnabled, phOut, tempOut, tdsOut, ecOut, tuOut);
  else
    initializeSDCard();

  elapsedTime = 0;
}

float readPh() {
  const int samples = 100;
  const int analogInPin = 34;
  int buf[samples];
  int temp = 0;
  unsigned long int inValue = 0;

  for (int i = 0; i < samples; i++) {
    buf[i] = analogRead(phPin);
    delay(10);
  }

  for (int i = 0; i < samples; i++) {
    for (int j = i + 1; j < samples - 1; j++) {
      temp = buf[i];
      buf[i] = buf[j];
      buf[j] = temp;
    }
  }

  for (int i = 10; i <= 90; i++) inValue = inValue + buf[i];

  float PHVol = (float) inValue * 100 * 3.3 / 4095 / 80;

  return -0.05 * PHVol + 20.75;
}

float readTDS(float temperature) {
  float averageVoltage = analogRead(tdsPin) * 3.3 / 4095.0;
  float compensationCoefficient = 1.0 + 0.02 * (temperature - 25.0);
  float compensationVoltage = averageVoltage / compensationCoefficient;

  return (133.42 * pow(compensationVoltage, 3) - 255.86 * pow(compensationVoltage, 2) + 857.39 * compensationVoltage) * 0.5;
}

float readConductivity(float tds) {
  return tds / 0.64;
}

float readTemperature() {
  dallasTemperature.requestTemperatures();
  return dallasTemperature.getTempCByIndex(0);
}

float readTurbidity() {
  return (float) map(analogRead(turbidityPin), 0, 4095, 3000, 4);
}

void wiFiAlarm() {
  digitalWrite(BUZZER, HIGH);
  delay(1500);
  digitalWrite(BUZZER, LOW);
  delay(1500);
}

void propertiesAlarm() {
  digitalWrite(ALARM_LED, HIGH);
  digitalWrite(BUZZER, HIGH);
  delay(500);
  digitalWrite(ALARM_LED, LOW);
  digitalWrite(BUZZER, LOW);
  delay(500);
}
