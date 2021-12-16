import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:widget_icon/ui/editWidget/edit_icon.dart';
import 'package:widget_icon/ui/newWidget/new_icon.dart';
import 'package:widget_icon/utils/platform_home_manager.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    () async {
      var startState = await PlatformHomeManager.instance.initStartState(context);
      setState(() {
        switch (startState.screen) {
          case Screen.NEW_ICON:
            Navigator.pushReplacementNamed(context, "/add_new", arguments: NewIconArguments(startState.widgetId, true));
            break;
          case Screen.EDIT_ICON:
            Navigator.pushReplacementNamed(context, "/edit", arguments: EditIconArguments(startState.widgetId, true));
            break;
          case Screen.LIST:
            Navigator.pushReplacementNamed(context, "/list");
            break;
          case Screen.ONBOARDING:
            Navigator.pushReplacementNamed(context, "/onboarding");
            break;
        }
      });
    }();
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
              Text('APP_NAME_FIRST'.tr(), style: const TextStyle(color: Colors.black, fontSize: 50, fontWeight: FontWeight.bold)),
              Text('APP_NAME_SECOND'.tr(), style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ));
  }
}
