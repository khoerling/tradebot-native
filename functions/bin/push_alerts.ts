import {
  admin,
  getUsers,
  saveUser,
  msgFromAlert,
  titleCase,
  User,
  Alert
} from "../src/helpers";
import * as P from "bluebird";

const util = require("util"),
  exec = util.promisify(require("child_process").exec),
  path = "../../mad-scientists-lab/ta/bin";

// init
// ---------
const adminConfig = require(__dirname + "/../service-account.json");
admin.initializeApp({ credential: admin.credential.cert(adminConfig) });

// main
// ---------
getUsers().then(async (users: Array<User>) => {
  for (let user of users) {
    const alerts = [];
    for (let alert of user.alerts) {
      // test alert
      if (alert.exchange && alert.market.symbol && alert.timeframe) {
        switch (alert.name) {
          case "price":
            alerts.push([
              alert,
              `${path}/price -x ${alert.exchange} -m ${
                alert.market.symbol
              } -t ${alert.timeframe} ${
                alert.params.price_horizon == "greater" ? "-g" : "-l"
              } ema ${alert.params.price_amount}`
            ]);
            break;
          case "divergence":
            alerts.push([
              alert,
              `${path}/divergence -x ${alert.exchange} -m ${
                alert.market.symbol
              } -t ${alert.timeframe} ${
                alert.params.divergence_hidden ? "-H" : ""
              } ${alert.params.divergence_bearish ? "-b" : ""}`
            ]);
            break;
          case "guppy":
            alerts.push([
              alert,
              `${path}/guppy -x ${alert.exchange} -m ${
                alert.market.symbol
              } -t ${alert.timeframe} --${
                alert.params.guppy == "grey" ? "gray" : alert.params.guppy
              }`
            ]);
            break;
        }
      }
    }
    // run all alerts for user simultaneously & wait
    await P.map(
      alerts,
      async ([alert, cmd]) => {
        await run(user, alert as Alert, cmd as string);
      },
      { concurrency: 10 } // maybe can be bumped up?
    );
    saveUser(user);
  }
  setTimeout(() => process.exit(1), 100); // die with slight yield
});

// ---------
async function run(user: User, alert: Alert, cmd: string) {
  try {
    console.log(`Running ${alert.name}: ${cmd}`);
    await exec(cmd);
    // send push notification
    console.log(
      `ALERT ${alert.exchange.toUpperCase()}: ${msgFromAlert(alert)}`
    );
    if (!alert.isSilenced)
      admin.messaging().sendToDevice(user.pushToken, {
        notification: {
          title: `${alert.name.toUpperCase()} on ${alert.market.symbol.toUpperCase()}`,
          body: `${titleCase(alert.exchange)} alerted ${msgFromAlert(alert)}`,
          data: { alert_id: alert.id },
          click_action: "FLUTTER_NOTIFICATION_CLICK"
        }
      });
    user.alerts = user.alerts.map(a => {
      if (a.id === alert.id) {
        // set isAlerted
        a.isAlerted = true;
        // add alerted time
        const now = new Date();
        a.updated = now;
        a.alerted.push(now);
      }
      return a;
    });
    return true;
  } catch (e) {
    // didn't trigger, so-- do nothing (for now)
    // - reset is_alerted state? likely not...
    // console.log(`error running ${alert.name}: ${e}`);
  }
  return false;
}
