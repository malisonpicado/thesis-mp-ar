const LocalDB = require("../core/local");
const Device = require("../core/device");
const { setNicaraguaTime } = require("../core/operations");
const { Firestore, Timestamp } = require("firebase-admin/firestore");

/**
 *
 * Esquema del cuerpo ("body") del "Request":
 *
 * ```
 * {
 *    "device_uuid": string,
 *    "device_name": string,
 *    "bluetooth_name": string,
 *    "bluetooth_macaddress": string,
 *    "server_url": string,
 *    "network_ssid": string,
 *    "sampling_time": number,
 *    "battery_min": number,
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
 *        "tu_max": number
 *    }
 * }
 * ```
 *
 * @param {import("express").Request} request Petición del cliente.
 * @param {import("express").Response} response Respuesta del servidor.
 * @param {Firestore} db Instancia de "Firestore".
 * @param {import("firebase-admin/database").Database} rtdb Instancia de "Firebase Realtime Database".
 * @param {LocalDB} localdb
 */
function saveNewDevice(request, response, db, rtdb, localdb) {
  const { body } = request;
  const today = new Date(setNicaraguaTime());
  const docRef = db.doc(`devices/${body.device_uuid}`);

  // Agregando los campos de datos adicionales
  body.created_date = Timestamp.fromDate(today);

  // Guardando los datos localmente
  const device = new Device(
    body.device_uuid,
    body.device_name,
    false,
    body.sampling_time,
  );
  localdb.addNewDevice(device);

  // Creando el esquema en "Firebase Realtime Database"
  rtdb
    .ref(`devices/${body.device_uuid}`)
    .set({
      battery_level: 0,
      time: today.toISOString(),
      connection: false,
      ph: 0.0,
      temperature: 0.0,
      tds: 0.0,
      conductivity: 0.0,
      turbidity: 0.0,
      bluetooth_enabled: false,
      alarm_enabled: false,
    })
    .catch(() => {
      response.sendStatus(500);
    });

  // Guardando en la base de datos "Firestore"
  docRef
    .set(body)
    .then(() => {
      response.sendStatus(200);
    })
    .catch(() => {
      response.sendStatus(500);
    });
}

module.exports = saveNewDevice;
