const { Firestore } = require("firebase-admin/firestore");
const LocalDB = require("../core/local");
const { updateLocalDB } = require("../other/other");

/**
 * Actualiza la información general del dispositivo de medición.
 *
 * Esquema del cuerpo ("body") del "Request":
 *
 * ```
 * {
 *    "network_ssid": string,
 *    "sampling_time": number,
 *    "battery_min": number,
 *    "server_url": number,
 *    "properties": {
 *        "ph_min": number,
 *        "ph_max": number,
 *        "te_min": number,
 *        "te_max": number,
 *        "tds_min": number,
 *        "tds_max": number,
 *        "ec_min": number,
 *        "ec_max": number,
 *        "tu_min": number,
 *        "tu_max": number,
 *    }
 * }
 * ```
 *
 * @param {import("express").Request} request Petición del cliente.
 * @param {import("express").Response} response Respuesta del servidor.
 * @param {Firestore} db Instancia de "Firestore".
 * @param {LocalDB} localdb
 */
async function updateDeviceInformation(request, response, db, localdb) {
  const { device_uuid } = request.params;
  const { body } = request;
  const docRef = db.doc(`devices/${device_uuid}`);

  // Actualiza el dispositivo en los datos locales
  if (localdb.devices.length === 0) {
    await updateLocalDB(db, localdb);
  }

  const deviceRef = localdb.getDevice(device_uuid);
  deviceRef.setSamplingTime(body.sampling_time);
  if (deviceRef.isConnected) deviceRef.toggleConnection();

  docRef
    .update(body)
    .then(() => {
      response.sendStatus(200);
    })
    .catch(() => {
      response.sendStatus(404);
    });
}

module.exports = updateDeviceInformation;
