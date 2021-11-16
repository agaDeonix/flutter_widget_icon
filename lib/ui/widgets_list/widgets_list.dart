import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/ui/editWidget/edit_icon.dart';
import 'package:widget_icon/ui/newWidget/new_icon.dart';
import 'package:widget_icon/utils/StringConstants.dart';
import 'package:widget_icon/utils/Utils.dart';

class WidgetsListScreen extends StatefulWidget {
  @override
  _WidgetsListScreenState createState() => _WidgetsListScreenState();
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await suspendingCallBack();
        break;
    }
  }
}

class _WidgetsListScreenState extends State<WidgetsListScreen> {
  List<String> _ids = [];
  Map<String, String> _widgets = {};
  SharedPreferences? _prefs;

  static const platform = MethodChannel('samples.flutter.dev/widgets');

  bool? _isSupportAddWidget = null;

  Future<void> _getIsSupportAddWidget() async {
    bool isSupportAddWidget;
    try {
      final bool result = await platform.invokeMethod('isSupportAddWidget');
      isSupportAddWidget = result;
    } on PlatformException catch (e) {
      isSupportAddWidget = false;
    }

    setState(() {
      _isSupportAddWidget = isSupportAddWidget;
    });
  }

  @override
  void initState() {
    super.initState();
    () async {
      _prefs = await SharedPreferences.getInstance();
      setState(() {});
    }();
    _getIsSupportAddWidget();
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      debugPrint('SystemChannels> $msg');
      if (msg == AppLifecycleState.resumed.toString() && _prefs != null) {
        _prefs!.reload().then((value) {
          setState(() {});
        });
      }
      ;
    });
    HomeWidget.updateWidget(
      name: 'SimpleAppWidget',
      androidName: 'SimpleAppWidget',
      iOSName: 'SimpleAppWidget',
    );
  }

  void _addNew() {
    Navigator.pushNamed(context, '/add_new', arguments: NewIconArguments(null, false)).then((value) {
      setState(() {});
    });
  }

  void _editItem(String id) {
    Navigator.pushNamed(context, '/edit', arguments: EditIconArguments(id, false)).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs != null) {
      _ids = _prefs!.getString("list_ids")?.split(",").where((element) => element.isNotEmpty).toList() ?? List.empty();
      for (var id in _ids) {
        _widgets["name_$id"] = _prefs!.getString("name_$id") ?? "";
        _widgets["path_$id"] = _prefs!.getString("path_$id") ?? "";
        _widgets["type_$id"] = (_prefs!.getString("type_$id") ?? "0");
      }
    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Виджеты"),
        backgroundColor: const Color(0xFFE6DFF1),
        elevation: 0,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _prefs == null && _isSupportAddWidget == null ? _initLoading() : (_ids.isEmpty ? _initEmpty() : _initList()),
      ),
    );
  }

  Widget _initLoading() {
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
            valueColor: new AlwaysStoppedAnimation<Color>(Utils.createMaterialColor(Color(0xFF8B56DD))),
          ),
        ),
      ],
    );
  }

  Widget _initEmpty() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("assets/images/ic_empty_help.png"),
        fit: BoxFit.scaleDown,
      )),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(Strings.EMPTY_TITLE, textAlign: TextAlign.left, style: const TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(Strings.EMPTY_MESSAGE, textAlign: TextAlign.left, style: const TextStyle(color: Colors.black54, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initList() {
    return ListView.builder(
      itemCount: _ids.length,
      itemBuilder: (context, index) {
        return _initItem(_ids[index], index == 0, index == _ids.length - 1);
      },
    );
  }

  Widget _initItem(String id, bool isFirst, bool isLast) {
    var name = _widgets["name_$id"]!;
    var path = _widgets["path_$id"]!;
    var type = int.parse(_widgets["type_$id"]!);
    var typeText = "Image";
    if (type == 1) {
      typeText = "Link";
    }
    return GestureDetector(
      onTap: () => _editItem(id),
      child: Card(
        margin: EdgeInsets.fromLTRB(10, isFirst ? 10 : 5, 10, isLast ? 10 : 5),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              getImageByType(type, path),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text("type: $typeText"),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.black38,
                size: 25.0,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getImageByType(int type, String path) {
    if (type == 0) {
      return Image.file(File(path), width: 50, height: 50, fit: BoxFit.cover);
    } else {
      return Image.asset("assets/images/ic_url.png", width: 50, height: 50, fit: BoxFit.cover);
    }
  }
}
