import { admin, getUsers, saveUser, User, Alert } from "../src/index";

const util = require("util"),
  exec = util.promisify(require("child_process").exec),
  path = "./bin/ta/bin";

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
            alerts.push(
              run(
                user,
                alert,
                `${path}/price -x ${alert.exchange} -m ${
                  alert.market.symbol
                } -t ${alert.timeframe} ${
                  alert.params.price_horizon == "greater" ? "-g" : "-l"
                } ema ${alert.params.price_amount}`
              )
            );
            break;
          case "divergence":
            alerts.push(
              run(
                user,
                alert,
                `${path}/divergence -x ${alert.exchange} -m ${
                  alert.market.symbol
                } -t ${alert.timeframe} ${
                  alert.params.divergence_hidden ? "-H" : ""
                } ${alert.params.divergence_bearish ? "-b" : ""}`
              )
            );
            break;
          case "guppy":
            alerts.push(
              run(
                user,
                alert,
                `${path}/guppy -x ${alert.exchange} -m ${
                  alert.market.symbol
                } -t ${alert.timeframe} --${alert.params.guppy}`
              )
            );
            break;
        }
      }
    }
    // run all alerts for user simultaneously & wait
    // - TODO add concurrency limit
    await Promise.all(alerts);
  }
  setTimeout(() => process.exit(1), 100); // die with slight yield
});

// ---------
async function run(user: User, alert: Alert, cmd: string) {
  try {
    console.log(`Running ${alert.name}: ${cmd}`);
    await exec(cmd);
    console.log(`ALERT ${alert.name}!`);
    // send push notification
    const opts =
      alert.params && Object.keys(alert.params).length
        ? JSON.stringify(alert.params)
        : "no options.";
    admin.messaging().sendToDevice(user.pushToken, {
      notification: {
        title: `${alert.name.toUpperCase()} ${alert.market.symbol.toUpperCase()}`,
        body: `${alert.exchange.toUpperCase()} triggered with ${opts}`
      }
    });
    user.alerts = user.alerts.map(a => {
      if (a.id === alert.id) {
        // set isAlerted
        alert.isAlerted = true;
        // add alerted time
        alert.alerted.push(new Date());
      }
      return alert;
    });
    saveUser(user);
    return true;
  } catch {
    // didn't trigger, so-- do nothing (for now)
    // - reset is_alerted state?
  }
  return false;
}
