import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:tradebot_native/models/alert.dart';
import 'package:tradebot_native/components/button.dart';

// TODO Replace with object model.
// try firebase only, cache with ccxt for market & exchange
// timeframe:  1H, 1M, 5M, 2H, 1D, 4W, (integer:letter)
// timeframe is not normalized, must come from exchange!  ccxt shows timeframes, use keys with api
// 5 alerts
// - horizontal, PRICE alert takes price input, can be directional, take up or down, > or <, run 2 alerts for both
// - guppy, did it turn green, grey or red
// - divergence, look for bullish or bearish + thresholds, --gap = 1 candle up to 50
// -

class CreateAlert extends StatefulWidget {
  const CreateAlert({
    Key key,
  }) : super(key: key);
  @override
  _CreateAlert createState() => _CreateAlert();
}

class _CreateAlert extends State<CreateAlert> {
  var exchanges = [], exchange;
  var markets = [], market;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchExchanges());
  }

  _fetchExchanges() async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'exchanges',
    );
    final res = await callable.call();
    setState(() => exchanges = res.data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SizedBox.expand(
      child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SearchableDropdown.single(
                  items: exchanges
                      .map((e) => DropdownMenuItem(
                          child: Text(e.toString()), value: e.toString()))
                      .toList(),
                  value: "",
                  hint: Padding(
                    padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                    child: Text("Select Exchange"),
                  ),
                  searchHint: "Select Exchange",
                  onChanged: (value) {
                    setState(() => exchange = value);
                  },
                  isExpanded: true,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 75.0),
                    child: Button(
                        child: Text(
                      "CREATE ALERT",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
              ])),
    ));
  }
}
