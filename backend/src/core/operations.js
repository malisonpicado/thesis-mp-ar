const moment = require("moment-timezone");
const { getMessaging } = require("firebase-admin/messaging");
const { Firestore, Query } = require("firebase-admin/firestore");

/**
 * Calcula el tiempo en la que un dispositivo de medición debe de volver
 * a enviar datos. Si ese tiempo no se cumple, se tomará como
 * desconexión del dispositivo. (Fecha en formato ISO)
 *
 * @param {number} samplingTime Tiempo de muestreo del dispositivo de medición.
 * @param {number} addSeconds Tiempo adicional para la recepción de datos.
 * @param {Date} currentDate Fecha actual del servidor.
 * @returns {Date} Fecha esperada por el servidor para la recepción de datos.
 */
function getExpectedTime(samplingTime, addSeconds, currentDate) {
  currentDate.setMinutes(
    currentDate.getMinutes() + samplingTime,
    currentDate.getSeconds() + addSeconds,
  );

  return currentDate;
}

function setNicaraguaTime() {
  const currentTime = moment();
  const nicaraguaTime = currentTime.clone().tz("America/Managua");

  return nicaraguaTime.toISOString();
}

function fromIsoToDateFormatted(isoString) {
  const fecha = new Date(isoString);

  const hora = convertirHoraISO(fecha.getHours()).toString().padStart(2, "0");
  const minutos = fecha.getMinutes().toString().padStart(2, "0");
  const dia = fecha.getDate().toString().padStart(2, "0");
  const mes = (fecha.getMonth() + 1).toString().padStart(2, "0");
  const anio = fecha.getFullYear().toString();

  const formatoPersonalizado = `${hora}:${minutos}-${dia}/${mes}/${anio}`;

  return formatoPersonalizado;
}

function convertirHoraISO(isoHour) {
  // Convertir la hora en formato ISO a formato de 24 horas
  const hora24 = (isoHour - 6) % 24;
  return hora24;
}

// =========================================================================
// Deleting entire collection
// https://firebase.google.com/docs/firestore/manage-data/delete-data?hl=es-419#collections
// =========================================================================

/**
 *
 * @param {Firestore} db
 * @param {string} collectionPath
 * @param {number} batchSize
 * @returns
 */
async function deleteCollection(db, collectionPath, batchSize) {
  const logsRef = db.collection(collectionPath);
  const q = logsRef.limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(db, q, resolve).catch(reject);
  });
}

/**
 *
 * @param {Firestore} db
 * @param {Query} query
 * @param {any} resolve
 * @returns
 */
async function deleteQueryBatch(db, query, resolve) {
  const snapshot = await query.get();

  const batchSize = snapshot.size;

  if (batchSize === 0) {
    resolve();
    return;
  }

  // Delete documents in a batch
  const batch = db.batch();

  // biome-ignore lint/complexity/noForEach: <explanation>
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();

  // Recurse on the next process tick, to avoid
  // exploding the stack.
  process.nextTick(() => {
    deleteQueryBatch(db, query, resolve);
  });
}
// =========================================================================

/**
 *
 * @param {Firestore} db
 * @param {String} deviceName
 * @param {String} props
 * @param {import("firebase-admin/app").App} app
 */
async function broadcastEmergencyNotification(db, deviceName, props, app) {
  const userCollection = db.collection("users");
  const snapshot = await userCollection.get();
  const registrationToken = snapshot.docs.map((doc) => doc.data().user_id);

  const message = {
    data: {
      device_name: deviceName,
      props: props.replace("|", ","),
    },
    notification: {
      title: `Emergencia en ${deviceName}`,
      body: `Las siguientes variables están fuera del rango permitido: ${propsListToText(
        props.split("|"),
      )}. Se recomienda tomar las medidas necesarias.`,
    },
    tokens: registrationToken,
  };

  getMessaging(app)
    .sendEachForMulticast(message)
    .then((response) => {})
    .catch((error) => {});
}

/**
 *
 * @param {Firestore} db
 * @param {String} deviceName
 * @param {import("firebase-admin/app").App} app
 */
async function broadcastDisconnectionNotification(db, deviceName, app) {
  const usersCollection = db.collection("users");
  const snapshot = await usersCollection.get();
  const registrationToken = snapshot.docs.map((doc) => doc.data().user_id);

  const message = {
    data: {
      device_name: deviceName,
    },
    notification: {
      title: `${deviceName} está desconectado.`,
      body: `Por favor, verifique la conexión a internet del dispositivo ${deviceName}.`,
    },
    tokens: registrationToken,
  };

  getMessaging(app)
    .sendEachForMulticast(message)
    .then((response) => {})
    .catch((error) => {});
}

/**
 *
 * @param {string} prop
 * @returns {string}
 */
function propsToText(prop) {
  switch (prop) {
    case "ph":
      return "pH";
    case "te":
      return "Temperatura";
    case "tds":
      return "TDS";
    case "ec":
      return "Conductividad Eléctrica";
    case "tu":
      return "Turbidez";
    default:
      return "";
  }
}

/**
 *
 * @param {string[]} props
 * @returns {string}
 */
function propsListToText(props) {
  const txt = [];

  for (const prop of props) {
    txt.push(propsToText(prop));
  }

  return txt.join(", ");
}

module.exports = {
  getExpectedTime,
  deleteCollection,
  setNicaraguaTime,
  broadcastEmergencyNotification,
  broadcastDisconnectionNotification,
  fromIsoToDateFormatted,
};
