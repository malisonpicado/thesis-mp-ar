const moment = require("moment-timezone");

/**
 *
 * @param {import("express").Response} response
 */
function getTime(response) {
  const fmt = "HH,mm,ss,DD,MM,YYYY";
  const tm = moment().clone().tz("America/Managua");
  const date = tm.format(fmt);

  response.status(200).send(date);
}

module.exports = getTime;
