import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:tradebot_native/pages/pages.dart';
import 'package:tradebot_native/pages/homepage.dart';

class Intro extends StatelessWidget {
  _close(context) {
    Navigator.push(
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
              pageColor: const Color(0xFFFFCC00),
              iconImageAssetPath: 'assets/images/dimension_icon.png',
              bubble: Image.asset('assets/images/dimension_icon.png'),
              body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Step 1',
                  )),
              title: Text(
                'Select a Market & Exchange!',
              ),
              titleTextStyle:
              TextStyle(fontFamily: 'fira', fontWeight: FontWeight.bold, fontSize: 50, color: Colors.black),
              bodyTextStyle:
                  TextStyle(fontFamily: 'fira', fontSize: 28, color: Colors.black),
                  mainImage: 
                  Icon(Icons.visibility, color: Colors.black, size: 125),),
          PageViewModel(
            pageColor: const Color(0xFF9E281A),
            iconImageAssetPath: 'assets/images/dimension_icon.png',
            body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Step 2',
                )),
            title: Text('Choose the Type of Alert!'),
            mainImage:
            Icon(Icons.visibility, color: Colors.white, size: 125),
            titleTextStyle:
            TextStyle(fontFamily: 'fira', fontWeight: FontWeight.bold, fontSize: 50, color: Colors.white),
            bodyTextStyle:
            TextStyle(fontFamily: 'fira', fontSize: 28, color: Colors.white),
          ),
          PageViewModel(
            // pageColor: const Color(0xFF607D8B),
            pageColor: Color.fromRGBO(18, 21, 54, 1),
            iconImageAssetPath: 'assets/images/dimension_icon.png',
            body: InkWell(
                onTap: () => _close(context),
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Step 3'
                    ))),
            title: InkWell(onTap: () => _close(context), child: Text('Alerts Push to Your Device in Realtime!')),
            mainImage: InkWell(
                onTap: () => _close(context),
                child:
                Icon(Icons.visibility, color: Colors.white, size: 125),),
            titleTextStyle: 
            TextStyle(fontFamily: 'fira', fontWeight: FontWeight.bold, fontSize: 50, color: Colors.white),
            bodyTextStyle: TextStyle(fontFamily: 'fira', color: Colors.white),
          ),
        ],
        showNextButton: false,
        showBackButton: false,
        showSkipButton: false,
        onTapDoneButton: () => _close(context),
        pageButtonTextStyles: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    );
  }
}
