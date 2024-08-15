const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");
const firebaseConfig = require("./firebase_config.js");
const bodyParser = require("body-parser");
const saveNewDevice = require("./routes/new.js");
const saveSensorsData = require("./routes/data.js");
const updateDeviceInformation = require("./routes/update.js");
const deleteDevice = require("./routes/delete.js");
const getHistory = require("./routes/history.js");
const LocalDB = require("./core/local.js");
const getDevicesUUID = require("./routes/devices.js");
require("dotenv").config();
const {
  setNicaraguaTime,
  broadcastDisconnectionNotification,
} = require("./core/operations.js");
const notify = require("./routes/notify.js");
const credentialCert = require("./credential_cert.js");
const btalarm = require("./routes/btalarm.js");
const getTime = require("./routes/time.js");

const port = process.env.PORT;

const fbApp = admin.initializeApp({
  ...firebaseConfig,
  credential: admin.credential.cert(credentialCert),
});

const app = express();

app.use(cors());
app.use(bodyParser.json());

const db = fbApp.firestore();

const rtdb = fbApp.database();
// rtdb.useEmulator("localhost", 9000);

const localdb = new LocalDB();

// Validación de conexión
setInterval(() => {
  const currentTime = new Date(setNicaraguaTime());

  for (const device of localdb.devices) {
    if (!device.isConnected) continue;

    if (currentTime.getTime() >= device.expectedUpdate.getTime()) {
      device.toggleConnection();
      broadcastDisconnectionNotification(db, device.deviceName, fbApp);

      rtdb
        .ref(`devices/${device.deviceId}/connection`)
        .set(false)
        .catch(() => {
          console.log("Error while updating device connection. FB REALTIME DB");
        });
    }
  }
}, 1000 * 5);

// Guarda la información de un nuevo dispositivo de medición.
app.post("/new", (req, res) => saveNewDevice(req, res, db, rtdb, localdb));

// Guarda la información proveniente del dispositivo de medición.
// ToDo: cloud messagging, validar si existe el dispositivo en la base de datos
app.post("/data", (req, res) => {
  saveSensorsData(req, res, db, rtdb, localdb);
});

// Comprueba la conexión entre el dispostivo de medición y este servidor
// Usado en la verificación de la URL del servidor (configuración de dispositivo de medición)
app.get("/verify", (req, res) => {
  res.sendStatus(200);
});

// Retorna una lista de las uuid de los dispositivos registrados
app.get("/devices", (_, response) => {
  getDevicesUUID(response, localdb, db);
});

// Actualiza la información general del dispositivo de medición
app.patch("/update/:device_uuid", (req, res) => {
  updateDeviceInformation(req, res, db, localdb);
});

// Elimina de las bases de datos un dispositivo
app.delete("/delete/:device_uuid", (req, res) => {
  deleteDevice(req, res, db, rtdb, localdb);
});

// Guarda en la base de datos los dispositivos móviles que
// serán notificados
app.post("/notify", (req, res) => {
  notify(req, res, db);
});

// Responde un con archivo .csv con los datos de los sensores
// a partir de una fecha de inicio y una de cierre
app.get("/history", (req, res) => {
  getHistory(req, res, db);
});

app.get("/btalarm", (req, res) => {
  btalarm(req, res, rtdb);
});

app.get("/manual", (req, res) => {
  res.download("public/manual.pdf");
});

app.get("/time", (req, res) => {
  getTime(res);
});

app.listen(port, () => {
  console.log("Server running.");
});
