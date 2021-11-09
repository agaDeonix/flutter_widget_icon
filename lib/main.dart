import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/ui/editWidget/edit_icon.dart';
import 'package:widget_icon/ui/newWidget/new_icon.dart';
import 'package:widget_icon/ui/splash/splash.dart';
import 'package:widget_icon/ui/widgets_list/widgets_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICON WIDGET',
      initialRoute: "/splash",
      routes: {
        '/splash': (context) => SplashScreen(),
        '/list': (context) => WidgetsListScreen(),
        '/add_new': (context) => NewIconScreen(),
        '/edit': (context) => EditIconScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
