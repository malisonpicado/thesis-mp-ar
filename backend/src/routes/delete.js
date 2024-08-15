const { deleteCollection } = require("../core/operations");
const LocalDB = require("../core/local");
const { Firestore } = require("firebase-admin/firestore");

/**
 * Elimina de todas las bases de datos un dispositivo de medición.
 *
 * @param {import("express").Request} request Petición del cliente.
 * @param {import("express").Response} response Respuesta del servidor.
 * @param {Firestore} db Instancia de "Firestore".
 * @param {import("firebase-admin/database").Database} rtdb Instancia de "Firebase Realtime Database".
 * @param {LocalDB} localdb
 */
function deleteDevice(request, response, db, rtdb, localdb) {
  const { device_uuid } = request.params;
  const docRef = db.doc(`devices/${device_uuid}`);
  const batchSize = 250;

  // Elimina el dispositivo de los datos locales
  if (localdb.devices.length !== 0) {
    localdb.removeDevice(device_uuid);
  }

  rtdb
    .ref(`devices/${device_uuid}`)
    .remove()
    .catch(() => {
      response.sendStatus(500);
    });

  deleteCollection(db, `${docRef.path}/logs`, batchSize)
    .then(() => {
      docRef
        .delete()
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

module.exports = deleteDevice;
