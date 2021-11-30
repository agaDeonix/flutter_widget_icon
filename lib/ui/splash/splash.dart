import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

import 'package:easy_localization/easy_localization.dart';
import 'package:widget_icon/ui/editWidget/edit_icon.dart';
import 'package:widget_icon/ui/newWidget/new_icon.dart';
import 'package:widget_icon/utils/Constants.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initReceiveIntent(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Color.fromARGB(255, 230, 223, 241),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/images/ic_splash.png", width: 150, height: 150, fit: BoxFit.cover),
              Text('APP_NAME_FIRST'.tr(), style: const TextStyle(color: Colors.black, fontSize: 50, fontWeight: FontWeight.bold )),
              Text('APP_NAME_SECOND'.tr(), style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold )),
            ],
          ),
        ],
      ),
    ));
  }

  Future<void> _initReceiveIntent(BuildContext context) async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    var isNewValue = false;
    var isEditValue = false;
    String? widgetId = null;
    try {
      final receivedIntent = await ReceiveIntent.getInitialIntent();
      if (receivedIntent != null && receivedIntent.action == "android.appwidget.action.APPWIDGET_CONFIGURE") {
        widgetId = receivedIntent.extra!["appWidgetId"].toString();
        var prefs = await SharedPreferences.getInstance();
        var widgetName = prefs.getString("name_$widgetId") ?? "";
        var widgetPath = prefs.getString("path_$widgetId") ?? "";
        if (widgetName.isNotEmpty && widgetPath.isNotEmpty) {
          isEditValue = true;
        } else {
          isNewValue = true;
        }
      }
    } on PlatformException {}
    var prefs = await SharedPreferences.getInstance();
    var isOnboardingShown = prefs.getBool(Constants.IS_ONBOARDING_SHOWN) ?? false;
    await Future.delayed(Duration(seconds: 1));
    setState(() {
        if (isNewValue) {
          Navigator.pushReplacementNamed(context, "/add_new", arguments: NewIconArguments(widgetId, true));
        } else if (isEditValue) {
          Navigator.pushReplacementNamed(context, "/edit", arguments: EditIconArguments(widgetId, true));
        } else {
          if(!isOnboardingShown) {
            Navigator.pushReplacementNamed(context, "/onboarding");
          } else {
            Navigator.pushReplacementNamed(context, "/list");
          }
        }
    });
  }

}
