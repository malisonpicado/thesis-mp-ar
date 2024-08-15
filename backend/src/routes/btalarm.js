/**
 *
 * @param {import("express").Request} request
 * @param {import("express").Response} response
 * @param {import("firebase-admin/database").Database} rtdb
 */
async function btalarm(request, response, rtdb) {
  const device_uuid = request.query.device_uuid;

  const alarm = await rtdb.ref(`devices/${device_uuid}/alarm_enabled`).get();
  const bluetooth = await rtdb.ref(`devices/${device_uuid}/bluetooth_enabled`).get();

  response.send(`${alarm.val()},${bluetooth.val()}`);
}

module.exports = btalarm;
