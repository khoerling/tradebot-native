import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:tradebot_native/components/crypto_icon.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:tradebot_native/pages/homepage.dart';

class Intro extends StatelessWidget {
  _close(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values); // show
  }

  // final TPage page;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]); // hide
    return Builder(
      builder: (context) => IntroViewsFlutter(
        [
          PageViewModel(
            pageColor: const Color(0xFF0FFCFF),
            iconImageAssetPath: 'assets/images/dimension_icon.png',
            bubble: Image.asset('assets/images/dimension_icon.png'),
            bubbleBackgroundColor: const Color(0x88000000),
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Step 1',
                )),
            title: Text(
              'Select a Market & Exchange!',
            ),
            titleTextStyle: TextStyle(
                fontFamily: 'fira',
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
                fontSize: 60,
                color: Colors.black),
            bodyTextStyle: TextStyle(
                fontFamily: 'fira', fontSize: 28, color: Colors.black),
            mainImage: CryptoIcon(
                height: 145.0, width: 145.0, color: Colors.black, name: 'BTC'),
          ),
          PageViewModel(
            pageColor: const Color(0xFF9EFF1A),
            bubbleBackgroundColor: const Color(0x88000000),
            iconImageAssetPath: 'assets/images/dimension_icon.png',
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Step 2',
                )),
            title: Text('Configure Your Alert!',
                style: TextStyle(color: Colors.black)),
            mainImage: Icon(Icons.visibility, color: Colors.black, size: 145),
            titleTextStyle: TextStyle(
                fontFamily: 'fira',
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
                fontSize: 60,
                color: Colors.black),
            bodyTextStyle: TextStyle(
                fontFamily: 'fira', fontSize: 28, color: Colors.black),
          ),
          PageViewModel(
            // pageColor: const Color(0xFF607D8B),
            bubbleBackgroundColor: const Color(0x88000000),
            pageColor: Color.fromRGBO(255, 21, 254, 1),
            iconImageAssetPath: 'assets/images/dimension_icon.png',
            body: InkWell(
                onTap: () => _close(context),
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('GOT IT'))),
            title: InkWell(
                onTap: () => _close(context),
                child: Text('Get Notified Realtime!',
                    style: TextStyle(color: Colors.black))),
            mainImage: InkWell(
              onTap: () => _close(context),
              child: Icon(Icons.notifications_active,
                  color: Colors.black, size: 145),
            ),
            titleTextStyle: TextStyle(
                fontFamily: 'fira',
                fontWeight: FontWeight.w400,
                letterSpacing: 3,
                fontSize: 60,
                color: Colors.black),
            bodyTextStyle: TextStyle(fontFamily: 'fira', color: Colors.black),
          ),
        ],
        showNextButton: false,
        showBackButton: false,
        showSkipButton: false,
        onTapDoneButton: () => _close(context),
        doneText: Text(" → "),
        pageButtonTextStyles: TextStyle(
          color: Colors.black,
          fontSize: 28.0,
        ),
      ),
    );
  }
}
