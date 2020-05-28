import { DocumentSnapshot } from "@firebase/firestore-types";

// init
// ---------
export const admin = require("firebase-admin"),
  ccxt = require("ccxt");

// shared types
// ---------
export type User = {
  id: string;
  pushToken: string;
  deviceId: string;
  email: string;
  alerts: Array<Alert>;
  created: Date;
  updated: Date;
};

export type Alert = {
  id: string;
  name: string;
  exchange: string;
  market: any;
  timeframe: string;
  alerted: Array<Date>;
  isAlerted: boolean;
  params: any;
  created: Date;
  updated: Date;
};

// helper fns
// --------
export const createExchange = (e: string) => {
  return e ? new ccxt[e]() : null;
};

export const getUsers = async () => {
  const users: Array<any> = [],
    snapshot = await admin
      .firestore()
      .collection("users")
      .get();
  snapshot.forEach((doc: DocumentSnapshot) => users.push(doc.data()));
  return users;
};

export const getAlerts = async () => {
  const userAlerts: Array<Alert> = [],
    snapshot = await getUsers();
  snapshot.forEach((doc: DocumentSnapshot) =>
    userAlerts.push(...doc.get("alerts"))
  );
  return userAlerts;
};

export const saveUser = async (user: User) => {
  admin
    .firestore()
    .collection("users")
    .doc(user.id)
    .set(user);
  return true;
};

export const msgFromAlert = (alert: Alert) => {
  switch (alert.name) {
    case "price":
      return `${alert.timeframe} Price ${alert.params.price_horizon} than ${
        alert.params.price_amount
      }.`;
    case "divergence":
      return `${alert.timeframe} ${
        alert.params.divergence_hidden ? "hidden" : ""
      } ${alert.params.divergence_bearish ? "Bearish" : "Bullish"} Divergence.`;
    case "guppy":
      return `${alert.timeframe} Guppy is ${alert.params.guppy.toUpperCase()}.`;
  }
  return `${alert.timeframe} on an Upcoming, Secret Trigger;  good luck!`;
};
