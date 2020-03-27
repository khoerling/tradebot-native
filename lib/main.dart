import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tradebot_native/pages/pages.dart';

const beppuTerminalBlue = Color.fromRGBO(18, 21, 54, 1);

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {'/list': (context) => ListAlerts(page: allPages[0])},
      theme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: beppuTerminalBlue,
        scaffoldBackgroundColor: beppuTerminalBlue.withOpacity(.97),
        cardColor: beppuTerminalBlue.withOpacity(.9),
        primaryColor: beppuTerminalBlue,
        accentColor: Color.fromRGBO(88, 41, 74, 1),
        textTheme: TextTheme(),
      ),
      home: HomePage()));
}
