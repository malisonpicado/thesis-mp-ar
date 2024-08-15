void runnable(void * p) {
  while (true) {
    if (isAlEnabled) {
      propertiesAlarm(); // 1s
      increaseElapsedTime(1);
    } else if (WiFi.status() != WL_CONNECTED) {
      wiFiAlarm(); // 3s
      increaseElapsedTime(3);
    } else {
      delay(1000);
      increaseElapsedTime(1);
    }
  }
}

void increaseElapsedTime(int increaseValue) {
  if (samplingTime == 0) return;

  elapsedTime += increaseValue;
}
