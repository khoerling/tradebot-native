import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:tradebot_native/models/user.dart';

const beppuTerminalBlue = Color.fromRGBO(18, 21, 54, 1);
final withOpacity = beppuTerminalBlue.withOpacity(.97);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // mandatory when awaiting on main
  // provide cached user object to all widgets
  var user = await User.restore();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: beppuTerminalBlue,
        scaffoldBackgroundColor: withOpacity,
        errorColor: Colors.white,
        hintColor: Colors.white,
        toggleableActiveColor: Colors.white,
        highlightColor: Colors.white,
        cardColor: Colors.black,
        primaryColor: beppuTerminalBlue,
        accentColor: Colors.white,
        textTheme: TextTheme(),
      ),
      home: MultiProvider(
          providers: [ListenableProvider<User>(create: (_) => user)],
          child: HomePage())));
}
