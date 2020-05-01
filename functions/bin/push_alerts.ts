import { admin, getUsers } from "../src/index";

// init
// ---------
const adminConfig = require(__dirname + "/../service-account.json");
admin.initializeApp({ credential: admin.credential.cert(adminConfig) });

// main
// ---------
getUsers().then(res => console.log(JSON.stringify(res)));
