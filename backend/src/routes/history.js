const { Firestore, Timestamp } = require("firebase-admin/firestore");
const createCsvWriter = require("csv-writer").createObjectCsvWriter;
const moment = require("moment-timezone");

/**
 * Query Parameters:
 * {
 *    "device_uuid": <device_uuid>
 *    "start": <fecha de inicio> DD-MM-YYYY
 *    "end": <fecha de finalización> DD-MM-YYYY
 * }
 *
 * @param {import("express").Request} request
 * @param {import("express").Response} response
 * @param {Firestore} db Instancia de firestoredb
 */
async function getHistory(request, response, db) {
  const device_uuid = request.query.device_uuid;
  const start = stringDateToIsoDate(request.query.start);
  const end = stringDateToIsoDate(request.query.end, false);
  const startDate = Timestamp.fromDate(new Date(start));
  const endDate = Timestamp.fromDate(new Date(end));

  const logsRef = db.collection(`devices/${device_uuid}/logs`);
  const logsQuery = logsRef
    .where("time", ">=", startDate)
    .where("time", "<=", endDate)
    .orderBy("time");

  const snapshot = await logsQuery.get();

  const documents = snapshot.docs.map((doc) => {
    const data = doc.data();
    const formattedTime = formattedDate(data.time.toDate());

    return {
      ...data,
      time: formattedTime,
    };
  });

  const csvWriter = createCsvWriter({
    path: "data.csv",
    header: [
      { id: "alarm_enabled", title: "Alarma Habilitada" },
      { id: "battery_level", title: "Nivel de Bateria" },
      { id: "bluetooth_enabled", title: "Bluetooth Habilitado" },
      { id: "conductivity", title: "Conductividad Electrica" },
      { id: "connection", title: "Conexion" },
      { id: "ph", title: "pH" },
      { id: "tds", title: "Total de Solidos Disueltos" },
      { id: "temperature", title: "Temperatura" },
      { id: "turbidity", title: "Turbidez" },
      { id: "time", title: "Fecha" },
    ],
  });

  await csvWriter.writeRecords(documents);
  response.download("data.csv");
}

/**
 * Formato de Firebase:
 * Wed Jul 03 2024 06:24:14 GMT-0600 (Central Standard Time)
 */
function formattedDate(date) {
  return moment(date).tz("America/Managua").format("HH:mm - DD/MM/YYYY");
}

/**
 * Converts date to ISO format
 *
 * @param {string} strDate date format: DD-MM-YYYY
 * @param {boolean} isStartDate set the time to 00:00 if start, else 23:59
 * @returns string
 */
function stringDateToIsoDate(strDate = "", isStartDate = true) {
  const format = "DD-MM-YYYY";

  let date = moment(strDate, format);

  date = date.tz("America/Managua");

  if (isStartDate) {
    date.add(1, "days").startOf("day");
  } else {
    date.add(2, "days").startOf("day");
  }

  return date.toISOString();
}

module.exports = getHistory;
