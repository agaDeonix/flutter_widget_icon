import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_intent/receive_intent.dart';
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
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Invoke "debug painting" (press "p" in the console, choose the
        // "Toggle Debug Paint" action from the Flutter Inspector in Android
        // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
        // to see the wireframe for each widget.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
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
    } else {
      if (isNewIconMode) {
        return MaterialApp(
          title: 'Widget icon',
          home: NewIconScreen(widgetId),
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        );
      } else {
        return MaterialApp(
          title: 'Widget icon',
          initialRoute: isNewIconMode ? '/add_new' : "/",
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/': (context) => WidgetsListScreen(),
            '/edit': (context) => EditIconScreen(),
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
    var value = false;
    try {
      final receivedIntent = await ReceiveIntent.getInitialIntent();
      if (receivedIntent != null &&
          receivedIntent.action ==
              "android.appwidget.action.APPWIDGET_CONFIGURE") {
        widgetId = receivedIntent.extra!["appWidgetId"].toString();
        value = true;
      }
      // Validate receivedIntent and warn the user, if it is not correct,
      // but keep in mind it could be `null` or "empty"(`receivedIntent.isNull`).
    } on PlatformException {
      // Handle exception
    }
    isWait = false;
    setState(() {
      isNewIconMode = value;
    });
  }
}
