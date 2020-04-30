// import * as functions from "firebase-functions";
// import { DocumentSnapshot } from "@firebase/firestore-types";
import { getAlerts } from "../src/index";

// const adminConfig = require("../functions/service-account.json");
// admin.initializeApp(adminConfig);

// main
// ---------
console.log(`alerts ${getAlerts()}`);
// HttpsCallable fetchAlerts = CloudFunctions.instance.getHttpsCallable(
//   functionName: 'alerts',
// );
// print('b4 fetch alerts -------');
// fetchAlerts.call().then((res) {
//   print("fetch alerts: ${res.data}");
// });
