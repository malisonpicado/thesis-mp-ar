const { Firestore } = require("firebase-admin/firestore");
const LocalDB = require("../core/local");
const { updateLocalDB } = require("../other/other");

/**
 * @param {import("express").Response} response
 * @param {LocalDB} localdb
 * @param {Firestore} db
 */
async function getDevicesUUID(response, localdb, db) {
  try {
    if (localdb.devices.length === 0) {
      await updateLocalDB(db, localdb);
    }

    const devices = buildDevicesArray(localdb.devices);
    response.set("Content-Type", "application/json");
    response.status(200).send(devices);
  } catch (error) {
    response.sendStatus(500);
  }
}

/**
 * @param {Device[]} devices
 * @returns {string[]} Arreglo de IDs de dispositivos en formato de cadena
 */
function buildDevicesArray(devices) {
  return devices.map((device) => device.deviceId.toString());
}

module.exports = getDevicesUUID;
