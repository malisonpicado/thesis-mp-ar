const { deviceValueData, newDeviceData, postData } = require("./dev.js");

const limit = 60;
const timeSeconds = 1 / 8;
let count = 1;
let deviceId = "";

postData(
  "http://localhost:3000/new",
  newDeviceData(1),
  (data) => {
    deviceId = data.uuid;
  },
  true,
).then(() => {
  streamData();
});

function streamData() {
  const interval = setInterval(() => {
    if (count <= limit) {
      postData(
        "http://localhost:3000/data",
        deviceValueData(0, deviceId),
        () => {},
        false,
      );
      count++;
    } else {
      clearInterval(interval);
    }
  }, 1000 * timeSeconds);
}
