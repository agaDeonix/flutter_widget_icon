import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/ui/editWidget/edit_icon.dart';
import 'package:widget_icon/ui/newWidget/new_icon.dart';
import 'package:widget_icon/ui/widgets_list/widgets_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isWait = true;
  var isNewIconMode = false;
  var isEditIconMode = false;
  var widgetId = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isWait = true;
    _initReceiveIntent(context);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (isWait) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              backgroundColor: Colors.white,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      );
      // return MaterialApp(
      //   title: 'Widget icon',
      //   home: Scaffold(
      //     appBar: AppBar(
      //       // Here we take the value from the MyHomePage object that was created by
      //       // the App.build method, and use it to set our appbar title.
      //       title: Text("Widgets list"),
      //     ),
      //     body: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         SizedBox(
      //           width: 50,
      //           height: 50,
      //           child: CircularProgressIndicator(
      //             strokeWidth: 5,
      //             backgroundColor: Colors.white,
      //             valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      //   theme: ThemeData(
      //     primarySwatch: Colors.blue,
      //   ),
      // );
    } else {
      if (isNewIconMode) {
        return MaterialApp(
          title: 'Widget icon',
          home: NewIconScreen(widgetId),
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        );
      } else if (isEditIconMode) {
        return MaterialApp(
          title: 'Widget icon',
          home: EditIconScreen(widgetId),
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        );
      } else {
        return MaterialApp(
          title: 'Widget icon',
          initialRoute: '/',
          routes: {
            '/': (context) => WidgetsListScreen(),
            '/add_new': (context) => NewIconScreen(null),
            '/edit': (context) => EditIconScreen(null),
          },
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        );
      }
    }
  }

  Future<void> _initReceiveIntent(BuildContext context) async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    var isNewValue = false;
    var isEditValue = false;
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
      // Validate receivedIntent and warn the user, if it is not correct,
      // but keep in mind it could be `null` or "empty"(`receivedIntent.isNull`).
    } on PlatformException {
      // Handle exception
    }
    isWait = false;
    setState(() {
      isNewIconMode = isNewValue;
      isEditIconMode = isEditValue;
    });
  }
}
