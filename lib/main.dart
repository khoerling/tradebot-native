import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:tradebot_native/pages/intro.dart';
import 'package:tradebot_native/models/user.dart';

const beppuTerminalBlue = Color.fromRGBO(18, 21, 54, 1);
final withOpacity = beppuTerminalBlue.withOpacity(.95);

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // mandatory when awaiting on main
  // provide cached user object to all widgets
  final user = await User.fromLocalStorage();
  runApp(MyApp(user: user));
  // freshen if able to connect
  user.stream();
}

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.user}) : super(key: key);
  final User user;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider<User>(create: (context) => user)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'fira',
          brightness: Brightness.dark,
          backgroundColor: beppuTerminalBlue,
          scaffoldBackgroundColor: withOpacity,
          errorColor: Colors.white,
          hintColor: Colors.white,
          toggleableActiveColor: Colors.white,
          highlightColor: Colors.white,
          cardColor: beppuTerminalBlue,
          primaryColor: beppuTerminalBlue,
          accentColor: Colors.white,
          textTheme: TextTheme(
              headline4: TextStyle(fontSize: 35.0, color: Colors.white),
              headline5: TextStyle(fontWeight: FontWeight.w100),
              headline6: TextStyle(
                  fontSize: 18, color: Colors.white.withOpacity(.85))),
        ),
        home: user.seenIntro < 4 ? Intro() : HomePage(),
      ),
    );
  }
}
