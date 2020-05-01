import { admin, getAlerts } from "../src/index";

// init
// ---------
const adminConfig = require(__dirname + "/../service-account.json");
admin.initializeApp({ credential: admin.credential.cert(adminConfig) });

// main
// ---------
getAlerts().then(res => console.log(JSON.stringify(res)));
