import { admin, getUsers, User, Alert } from "../src/index";

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
    for (let alert of user.alerts) {
      // test alert
      if (alert.exchange && alert.market.symbol && alert.timeframe) {
        switch (alert.name) {
          case "price":
            run(
              alert,
              user.pushToken,
              `${path}/price -x ${alert.exchange} -m ${
                alert.market.symbol
              } -t ${alert.timeframe} ${
                alert.params.price_horizon == "greater" ? "-g" : "-l"
              } ema ${alert.params.price_amount}`
            );
            break;
          case "divergence":
            run(
              alert,
              user.pushToken,
              `${path}/divergence -x ${alert.exchange} -m ${
                alert.market.symbol
              } -t ${alert.timeframe} ${
                alert.params.divergence_hidden ? "-H" : ""
              } ${alert.params.divergence_bearish ? "-b" : ""}`
            );
            break;
          case "guppy":
            run(
              alert,
              user.pushToken,
              `${path}/guppy -x ${alert.exchange} -m ${
                alert.market.symbol
              } -t ${alert.timeframe} --${alert.params.guppy}`
            );
            break;
        }
      }
    }
    console.log("finished alerts");
  }
  console.log("done.");
  setTimeout(() => process.exit(1), 100); // die
});

// ---------
async function run(alert: Alert, token: string, cmd: string) {
  try {
    console.log(`Running ${alert.name}: ${cmd}`);
    await exec(cmd);
    console.log(`ALERT ${alert.name}!`);
    // send push notification
    const opts =
      alert.params && Object.keys(alert.params).length
        ? JSON.stringify(alert.params)
        : "no options.";
    admin.messaging().sendToDevice(token, {
      notification: {
        title: `${alert.name.toUpperCase()} ${alert.market.symbol.toUpperCase()}`,
        body: `${alert.exchange.toUpperCase()} triggered with ${opts}`
      }
    });
    // set is_alerted
    // update db that alerted @ time, etc...
    return true;
  } catch {
    // didn't trigger, so-- do nothing (for now)
    // - reset is_alerted state?
  }
  return false;
}
