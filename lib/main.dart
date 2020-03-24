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
        scaffoldBackgroundColor: beppuTerminalBlue,
        primaryColor: beppuTerminalBlue,
        accentColor: Colors.yellow[900],
        textTheme: TextTheme(),
      ),
      home: HomePage()));
}
