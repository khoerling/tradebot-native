import * as functions from "firebase-functions";
import { DocumentSnapshot } from "@firebase/firestore-types";

export type Alert = {
  id: string;
  name: string;
  exchange: string;
  market: object;
  timeframe: string;
  alerted: Date;
  created: Date;
  updated: Date;
  params: Map<string, any>;
};

export const admin = require("firebase-admin"),
  ccxt = require("ccxt"),
  serviceAccount = require("../service-account.json"),
  adminConfig = JSON.parse(process.env.FIREBASE_CONFIG || "");

// init
// ---------
adminConfig.credential = admin.credential.cert(serviceAccount);
admin.initializeApp(adminConfig);

// fns
// ---------
export const addUser = functions.https.onCall((data, _context) => {
  // XXX currently happens directly via firestore db in app
  // - implement this if needed externally, eg. from cr0n
  const users = admin.firestore().collection("users");
  return users.add({
    name: data["name"],
    email: data["email"]
  });
});

export const exchanges = functions.https.onCall((_data, _context) => {
  // TODO limit and cache exchanges on apiKeys
  try {
    return { success: true, exchanges: ccxt.exchanges };
  } catch (error) {
    return { success: false, error };
  }
});

export const markets = functions.https.onCall(async (data, _context) => {
  try {
    const exchange = createExchange(data.exchange),
      mkts = await exchange.fetchMarkets(),
      mkt = mkts.filter((m: any) => m.id && m.active).map((m: any) => {
        return { id: m.id, symbol: m.symbol, base: m.base, quote: m.quote };
      });
    return { success: true, timeframes: exchange.timeframes, markets: mkt };
  } catch (error) {
    return { success: false, error };
  }
});

export const alerts = functions.https.onCall(async (_data, _context) => {
  try {
    const userAlerts = await getAlerts();
    return { success: true, alerts: userAlerts };
  } catch (error) {
    return { success: false, error };
  }
});

// helpers
// --------
function createExchange(e: string) {
  return e ? new ccxt[e]() : null;
}

export const getAlerts = async () => {
  const userAlerts: Array<Alert> = [],
    snapshot = await admin
      .firestore()
      .collection("users")
      .get();
  snapshot.forEach((doc: DocumentSnapshot) =>
    userAlerts.push(doc.get("alerts"))
  );
};
