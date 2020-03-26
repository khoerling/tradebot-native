import * as functions from "firebase-functions";

const admin = require("firebase-admin"),
  ccxt = require("ccxt");

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

export const addUser = functions.https.onCall((data, _context) => {
  const users = admin.firestore().collection("users");
  return users.add({
    name: data["name"],
    email: data["email"]
  });
});

export const exchanges = functions.https.onCall((_data, _context) => {
  console.log(ccxt.exchanges);
  return ccxt.exchanges;
});

export const markets = functions.https.onCall(async (data, _context) => {
  const exchange = createExchange(data.exchange),
    markets = await exchange.fetchMarkets(),
    m = markets.filter((m: any) => m.id && m.active).map((m: any) => {
      return { id: m.id, name: m.name };
    });
  return { timeframes: exchange.timeframes, markets: m };
});

// helpers
// --------
function createExchange(e: string) {
  return e ? new ccxt[e]() : null;
}
