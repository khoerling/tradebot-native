import { ccxt, createExchange } from "../src/helpers";
// import * as P from "bluebird";

// main
// ---------
const exchanges: Array<string> = [];
(async () => {
  for await (let e of ccxt.exchanges) {
    try {
      const exchange = createExchange(e);
      const mkts = await exchange.fetchMarkets();
      if (mkts.length) exchanges.push(e);
    } catch (e) {}
  }
  console.log(exchanges);
})();
