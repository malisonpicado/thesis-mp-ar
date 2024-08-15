const LocalDB = require("../core/local");
const Device = require("../core/device");
const { Firestore } = require("firebase-admin/firestore");

/**
 * @param {Firestore} db
 * @param {LocalDB} localdb
 * @returns {Promise<boolean>} Retorna true si se ha actualizado la base de datos local correctamente, de lo contrario retorna false.
 */
async function updateLocalDB(db, localdb) {
  try {
    const querySnapshot = await db.collection("devices").get();

    // biome-ignore lint/complexity/noForEach: <explanation>
    querySnapshot.forEach((doc) => {
      const data = doc.data();
      localdb.addNewDevice(
        new Device(
          data.device_uuid,
          data.device_name,
          true,
          data.sampling_time,
        ),
      );
    });

    return true;
  } catch (error) {
    console.log("Error:", error);
    return false;
  }
}

module.exports = { updateLocalDB };
