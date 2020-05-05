import * as functions from "firebase-functions";
import { admin, ccxt, createExchange, getAlerts } from "./helpers";

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
