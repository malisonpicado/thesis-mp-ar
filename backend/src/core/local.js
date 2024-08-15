const Device = require("./device");

class LocalDB {
  constructor() {
    /**
     * @type {Array<Device>}
     */
    this.devices = [];
  }

  /**
   *
   * @param {Device} device
   */
  addNewDevice(device) {
    this.devices.push(device);
  }

  /**
   *
   * @param {string} deviceId
   */
  removeDevice(deviceId) {
    if (deviceId === "" || deviceId === undefined) return;

    const targetDevice = this.devices.find(
      (device) => device.deviceId === deviceId,
    );

    const deviceIndex = this.devices.indexOf(targetDevice);
    this.devices.splice(deviceIndex, 1);
  }

  /**
   *
   * @param {string} deviceId
   * @returns {Device}
   */
  getDevice(deviceId) {
    if (deviceId === "" || deviceId === undefined) return;

    const targetDevice = this.devices.find(
      (device) => device.deviceId === deviceId,
    );

    const deviceIndex = this.devices.indexOf(targetDevice);
    return this.devices[deviceIndex];
  }
}

module.exports = LocalDB;
