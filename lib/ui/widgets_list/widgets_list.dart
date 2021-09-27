import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    Navigator.pushNamed(context, '/add_new').then((value) {
      setState(() {});
    });
  }

  void _editItem(String id) {
    Navigator.pushNamed(context, '/edit', arguments: id).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs != null) {
      _ids = _prefs!
              .getString("list_ids")
              ?.split(",")
              .where((element) => element.isNotEmpty)
              .toList() ??
          List.empty();
      for (var id in _ids) {
        _widgets["name_$id"] = _prefs!.getString("name_$id") ?? "";
        _widgets["path_$id"] = _prefs!.getString("path_$id") ?? "";
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
        title: Text("Widgets list"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _prefs == null && _isSupportAddWidget == null
            ? _initLoading()
            : (_ids.isEmpty ? _initEmpty() : _initList()),
      ),
      floatingActionButton:
          _isSupportAddWidget == null || _isSupportAddWidget == false
              ? SizedBox()
              : FloatingActionButton(
                  onPressed: _addNew,
                  tooltip: 'Add new widget',
                  child: Icon(Icons.add)), // This
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
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _initEmpty() {
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
        Text(
          'You haven\'t added icons,\npush on "+" button for adding new Icon',
          textAlign: TextAlign.center,
        ),
      ],
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
    return GestureDetector(
      onTap: () => _editItem(id),
      child: Card(
        margin: EdgeInsets.fromLTRB(10, isFirst ? 10 : 5, 10, isLast ? 10 : 5),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.file(File(path), width: 50, height: 50, fit: BoxFit.cover),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text("type: Image"),
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
}
