const fetch = require("node-fetch");
const { v4: uuidv4 } = require("uuid");

const devicesIdList = [];
const samplingTime = 1;

// Data for adding a new device to database
function newDeviceData(samplingMinutes = 0) {
  const deviceName = [
    "Managua",
    "Leon",
    "Chinandega",
    "Masaya",
    "Granada",
    "Carazo",
    "Rivas",
  ];
  const SSID = [
    "xolotlan",
    "cerro_negro",
    "cosiguina",
    "santiago",
    "catedral",
    "diriamba",
    "san_juan_del_sur",
  ];
  const selectedItem = getRandomValue(0, deviceName.length);

  return {
    device_uuid: uuidv4(),
    device_name: `${deviceName[selectedItem]} ${selectedItem}`,
    bluetooth_name: `${deviceName[selectedItem].toLowerCase()}${selectedItem}`,
    network_ssid: SSID[selectedItem],
    sampling_time: samplingMinutes === 0 ? samplingTime : samplingMinutes,
    battery_min: getRandomValue(10, 25),
    bluetooth_macaddress: "43:5T:2D:RA:R3",
    properties: {
      ph_min: getRandomValue(5, 6),
      ph_max: getRandomValue(8, 10),
      te_min: getRandomValue(25, 28),
      te_max: getRandomValue(30, 32),
      tds_min: getRandomValue(500, 600),
      tds_max: getRandomValue(800, 850),
      ec_min: getRandomValue(9, 10),
      ec_max: getRandomValue(12, 13),
    },
  };
}

// Data comming from devices
function deviceValueData(deviceIdIndex = 0, device_id = "") {
  return {
    device_uuid: device_id === "" ? devicesIdList[deviceIdIndex] : device_id,
    battery_level: getRandomValue(50, 100),
    time: new Date().toISOString(),
    connection: true,
    ph: getRandomValue(0, 14),
    conductivity: getRandomValue(0, 16),
    temperature: getRandomValue(20, 40),
    tds: getRandomValue(100, 1000),
    bluetooth_enabled: false,
    alarm_enabled: false,
    critical_props: [],
  };
}

function getRandomValue(min, max) {
  const randomNumber = Math.random();
  const inRangeNumber = randomNumber * (max - min) + min;
  const value = Number(inRangeNumber.toFixed(0));

  return value;
}

async function postData(url, data, fn = (res_data) => {}, expectJSON = false) {
  try {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    if (expectJSON) {
      const responseData = await response.json();
      fn(responseData);
    } else {
      fn("");
    }
  } catch (error) {
    console.error("Error:", error.message);
  }
}

let times = 1;

function start() {
  const interval = setInterval(() => {
    if (times <= 3) {
      const data = newDeviceData();
      postData("http://localhost:3000/new", data, (d) => {}, false);
      devicesIdList.push(data.device_uuid);
      times++;
    }

    if (times > 3) {
      clearInterval(interval);
    }
  }, 2000);

  const interval2 = setInterval(
    () => {
      if (times > 3) {
        if (Math.random() > 0.4) {
          postData(
            "http://localhost:3000/data",
            deviceValueData(0),
            () => {},
            false,
          );
        } else {
          console.log(`Device ${devicesIdList[0]} has been disconnected`);
        }
        if (Math.random() > 0.4) {
          postData(
            "http://localhost:3000/data",
            deviceValueData(1),
            () => {},
            false,
          );
        } else {
          console.log(`Device ${devicesIdList[1]} has been disconnected`);
        }
        if (Math.random() > 0.4) {
          postData(
            "http://localhost:3000/data",
            deviceValueData(2),
            () => {},
            false,
          );
        } else {
          console.log(`Device ${devicesIdList[2]} has been disconnected`);
        }
        console.log(
          "--------------------------------------------------------------------",
        );
      }
    },
    1000 * 60 * samplingTime,
  );
}

start();

module.exports = { newDeviceData, deviceValueData, postData };
