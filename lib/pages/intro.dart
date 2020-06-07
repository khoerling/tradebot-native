import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:tradebot_native/models/user.dart';
import 'package:tradebot_native/components/crypto_icon.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:tradebot_native/pages/homepage.dart';

class Intro extends StatelessWidget {
  _close(context) {
    // set intro as seen
    final user = Provider.of<User>(context, listen: false);
    user
      ..seenIntro = 2
      ..save();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  // final TPage page;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]); // hide
    return Builder(
      builder: (context) => IntroViewsFlutter(
        [
          PageViewModel(
            pageColor: const Color(0xFF0F9FFF),
            iconImageAssetPath: 'assets/images/dimension_icon.png',
            bubble: Image.asset('assets/images/dimension_icon.png'),
            bubbleBackgroundColor: const Color(0xFFFFFFFF),
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Step 1:  Select your favorite combinations.',
                )),
            title: Text(
              'Exchanges & Markets',
            ),
            titleTextStyle: TextStyle(
                fontFamily: 'fira',
                fontWeight: FontWeight.w400,
                fontSize: 35,
                color: Colors.white),
            bodyTextStyle: TextStyle(
                fontFamily: 'fira', fontSize: 20, color: Colors.white),
            mainImage: CryptoIcon(
                height: 145.0, width: 145.0, color: Colors.white, name: 'BTC'),
          ),
          PageViewModel(
            pageColor: Color.fromRGBO(15, 205, 04, 1),
            bubbleBackgroundColor: const Color(0xFFFFFFFF),
            iconImageAssetPath: 'assets/images/dimension_icon.png',
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Step 2: Configure your parameters.',
                )),
            title: Text('Alerts', style: TextStyle(color: Colors.white)),
            mainImage: Icon(Icons.visibility, color: Colors.white, size: 145),
            titleTextStyle: TextStyle(
                fontFamily: 'fira',
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
                fontSize: 35,
                color: Colors.white),
            bodyTextStyle: TextStyle(
                fontFamily: 'fira', fontSize: 20, color: Colors.white),
          ),
          PageViewModel(
            bubbleBackgroundColor: const Color(0xFFFFFFFF),
            pageColor: Color.fromRGBO(255, 21, 154, 1),
            iconImageAssetPath: 'assets/images/dimension_icon.png',
            body: InkWell(
                onTap: () => _close(context),
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Step 3:  Get notified in realtime!'))),
            title: InkWell(
                onTap: () => _close(context),
                child: Text('Notifications',
                    style: TextStyle(color: Colors.white))),
            mainImage: InkWell(
              onTap: () => _close(context),
              child: Icon(Icons.notifications_active,
                  color: Colors.white, size: 145),
            ),
            titleTextStyle: TextStyle(
                fontFamily: 'fira',
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
                fontSize: 35,
                color: Colors.white),
            bodyTextStyle: TextStyle(fontFamily: 'fira', color: Colors.white),
          ),
        ],
        showNextButton: true,
        fullTransition: 150,
        showBackButton: false,
        showSkipButton: false,
        onTapDoneButton: () => _close(context),
        doneText: Text("OK"),
        nextText: Text(" → "),
        pageButtonTextStyles: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
    );
  }
}
