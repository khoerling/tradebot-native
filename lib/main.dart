import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:tradebot_native/pages/intro.dart';
import 'package:tradebot_native/models/user.dart';

// const beppuTerminalBlue = Color.fromRGBO(18, 21, 54, 1);
const backgroundColor = Color.fromRGBO(0, 0, 0, 1),
    themeColor = Color.fromRGBO(157, 67, 253, 1);
final withOpacity = backgroundColor.withOpacity(.95);

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
        child: GestureDetector(
          onTap: () {
            // allow keyboard to be dismissed by losing focus
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild.unfocus();
            }
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'fira',
              brightness: Brightness.dark,
              backgroundColor: backgroundColor,
              scaffoldBackgroundColor: withOpacity,
              errorColor: Colors.white,
              hintColor: themeColor,
              toggleableActiveColor: Colors.white,
              highlightColor: Colors.white.withOpacity(.1),
              cardColor: backgroundColor,
              primaryColor: backgroundColor,
              accentColor: themeColor,
              textTheme: TextTheme(
                  headline4: TextStyle(fontSize: 35.0, color: Colors.white),
                  headline5: TextStyle(fontWeight: FontWeight.w100),
                  headline6: TextStyle(
                      fontSize: 18, color: Colors.white.withOpacity(.85))),
            ),
            home: user.seenIntro < 3 ? Intro() : HomePage(),
          ),
        ));
  }
}
