const LocalDB = require("../core/local");
const { updateLocalDB } = require("../other/other");
const {
  setNicaraguaTime,
  broadcastEmergencyNotification,
} = require("../core/operations");
const { Firestore, Timestamp } = require("firebase-admin/firestore");
const moment = require("moment-timezone");

/**
 * Esquema del cuerpo ("body") del "Request":
 *
 * ```
 * {
 *    "device_uuid": string,
 *    "battery_level": number,
 *    "connection": bool,
 *    "ph": number,
 *    "conductivity": number,
 *    "temperature": number,
 *    "tds": number,
 *    "turbidity": number,
 *    "bluetooth_enabled": bool,
 *    "alarm_enabled": bool,
 *    "critical_props": "ph|te|tds|ec|tu" [Agregarlas luego, ejemplo: "critical_props": "ph|tds", => para ph y tds] vacío: "critical_props": "_"
 * }
 * ```
 *
 * @param {import("express").Request} request Petición del cliente.
 * @param {import("express").Response} response Respuesta del servidor.
 * @param {Firestore} db Instancia de "Firestore".
 * @param {import("firebase-admin/database").Database} rtdb Instancia de "Firebase Realtime Database".
 * @param {LocalDB} localdb
 * @param {import("firebase-admin/app").App} app
 */
async function saveSensorsData(request, response, db, rtdb, localdb, app) {
  const nicaraguaTime = setNicaraguaTime();
  const { body } = request;
  const docRef = db.doc(`devices/${body.device_uuid}`);
  const subCollRef = db.collection(`${docRef.path}/logs`);
  const deviceId = body.device_uuid;

  // Añadiendo fecha de ingreso de datos
  body.time = Timestamp.fromDate(new Date(nicaraguaTime));

  // Actualiza la información del dispositivo en el almacenamiento local
  if (localdb.devices.length === 0) {
    await updateLocalDB(db, localdb);
  }

  const deviceRef = localdb.getDevice(body.device_uuid);
  deviceRef.setExpectedUpdate(new Date(nicaraguaTime));
  if (!deviceRef.isConnected) deviceRef.toggleConnection();

  if (body.critical_props !== "") {
    broadcastEmergencyNotification(
      db,
      deviceRef.deviceName,
      body.critical_props,
      app,
    );
  }

  // biome-ignore lint/performance/noDelete: simplify development
  delete body.device_uuid;

  // biome-ignore lint/performance/noDelete: simplify development
  delete body.critical_props;

  // Añadiendo datos a la base de datos "Firestore"
  subCollRef
    .add(body)
    .then(() => {
      // Guardar "time" en formato ISOString para Realtime Database
      body.time = `${moment().clone().tz("America/Managua").format("YYYY-MM-DDTHH:mm:ss.000")}Z`;
      
      // Actualizando en "Realtime Database"
      rtdb
        .ref(`devices/${deviceId}`)
        .set(body)
        .then(() => {
          response.sendStatus(200);
        })
        .catch(() => {
          response.sendStatus(500);
        });
    })
    .catch(() => {
      response.sendStatus(500);
    });
}

module.exports = saveSensorsData;
