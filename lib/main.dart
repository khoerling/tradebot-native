import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tradebot_native/pages/pages.dart';

const beppuTerminalBlue = Color.fromRGBO(18, 21, 54, 1);

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: beppuTerminalBlue,
        scaffoldBackgroundColor: beppuTerminalBlue.withOpacity(.87),
        errorColor: Colors.white,
        hintColor: Colors.white,
        toggleableActiveColor: Colors.white,
        highlightColor: Colors.white,
        cardColor: beppuTerminalBlue.withOpacity(.9),
        primaryColor: beppuTerminalBlue,
        accentColor: Colors.white,
        textTheme: TextTheme(),
      ),
      home: HomePage()));
}
