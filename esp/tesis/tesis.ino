#include <BluetoothSerial.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <FS.h>
#include <SD.h>
#include <SPI.h>
#include <ESP32Time.h>

#define tdsPin 33
#define tdsPositive 14
#define phPin 34
#define tePin 15
#define turbidityPin 35
#define sdPin 5
#define batteryPin 36
#define SD_LED 21
#define WIFI_LED 17
#define ALARM_LED 16
#define BT_LED 27
#define BUZZER 26

OneWire oneWire(tePin);
DallasTemperature dallasTemperature(&oneWire);

BluetoothSerial SerialBT;

ESP32Time rtc(0);

float PH_min = 0.0;
float PH_max = 0.0;
float TEMP_min = 0.0;
float TEMP_max = 0.0;
float TDS_min = 0.0;
float TDS_max = 0.0;
float EC_min = 0.0;
float EC_max = 0.0;
float TU_min = 0.0;
float TU_max = 0.0;
String ssid = "";
String password = "";
String serverUrl = "";
String deviceUUID = "";
String incomingUUID = "";
int samplingTime = 0;
int batteryMin = 0;

bool isBTEnabled = false;
bool isAlEnabled = false;
bool isSDCardEnabled = false;
int elapsedTime = 0;

String dateTimeString = "";
int parsedTime[6];

TaskHandle_t taskHandle;

void setup() {
  Serial.begin(115200);
  pinMode(phPin, INPUT);
  pinMode(turbidityPin, INPUT);
  pinMode(batteryPin, INPUT);
  pinMode(tdsPin, INPUT);
  pinMode(tdsPositive, OUTPUT);
  pinMode(SD_LED, OUTPUT);
  pinMode(WIFI_LED, OUTPUT);
  pinMode(ALARM_LED, OUTPUT);
  pinMode(BT_LED, OUTPUT);
  pinMode(BUZZER, OUTPUT);
  dallasTemperature.begin();
  onDeviceStart();
  xTaskCreatePinnedToCore(runnable, "task", 10000, NULL, 0, &taskHandle, 0);
}

void loop() {
  if (isBTEnabled) readIncomingBluetoothData();
  else {
    measure();
    sdcardLightAlert();
    wifiLighAlert();
    String response = getUserAction();

    if (response != "") setBtalarm(response);

    delay(2000);
  }
}

void onDeviceStart() {
  initializeStorage();
  loadDeviceConfiguration();

  sdcardLightAlert();
  wifiLighAlert();

  if (deviceUUID == "") {
    enableBluetooth();
    return;
  }

  if (!initializeWiFi()) {
    digitalWrite(WIFI_LED, HIGH);
    return;
  }

  // Estableciendo la fecha y hora en el dispositivo:
  dateTimeString = fetchTime(); // hora,minutos,segundos,dia,mes,año
  timeParser(dateTimeString, parsedTime);
  // Argumentos: segundos, minutos, horas, dia, mes, año
  rtc.setTime(parsedTime[2], parsedTime[1], parsedTime[0], parsedTime[3], parsedTime[4], parsedTime[5]);
}
