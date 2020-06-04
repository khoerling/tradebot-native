import { ccxt, createExchange } from "../src/helpers";

// main
// ---------
const exchanges: Array<string> = [];
(async () => {
  for await (let e of ccxt.exchanges) {
    try {
      const exchange = createExchange(e);
      const mkts = await exchange.fetchMarkets();
      if (mkts.length > 1) exchanges.push(e);
    } catch (e) {}
  }
  console.log(exchanges);
})();
