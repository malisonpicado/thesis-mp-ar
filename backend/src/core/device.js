const { getExpectedTime, setNicaraguaTime } = require("../core/operations");

class Device {
  /**
   *
   * @param {string} deviceId UUID del dispositivo de monitoreo
   * @param {boolean} isConnected Estado de conexión del dispositivo
   * @param {number} samplingTime Tiempo de muestreo del dispositivo (minutos)
   * @param {string} deviceName Nombre del dispositivo
   */
  constructor(deviceId, deviceName, isConnected = false, samplingTime = 1) {
    if (deviceId === undefined || deviceId === "")
      throw "deviceId should not be empty or undefined";

    this.isConnected = isConnected;
    this.samplingTime = samplingTime;
    this.expectedUpdate = getExpectedTime(
      samplingTime,
      20,
      new Date(setNicaraguaTime()),
    );
    this.deviceId = deviceId;
    this.deviceName = deviceName;
  }

  /**
   *
   * @param {number} samplingTime Tiempo de muestreo del dispositivo (minutos)
   */
  setSamplingTime(samplingTime = 1) {
    this.samplingTime = samplingTime;
  }

  toggleConnection() {
    this.isConnected = !this.isConnected;
  }

  /**
   *
   * @param {Date} currentDate
   * @param {number} addSeconds
   */
  setExpectedUpdate(currentDate, addSeconds = 20) {
    this.expectedUpdate = getExpectedTime(
      this.samplingTime,
      addSeconds,
      currentDate,
    );
  }
}

module.exports = Device;
