import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/ui/base/icon_data.dart';

import 'package:easy_localization/easy_localization.dart';

class NewIconScreen extends StatefulWidget {
  const NewIconScreen({Key? key}) : super(key: key);

  @override
  _NewIconScreenState createState() => _NewIconScreenState();
}

class NewIconArguments {
  String? widgetId;
  bool isConfig;

  NewIconArguments(this.widgetId, this.isConfig);
}

class _NewIconScreenState extends State<NewIconScreen> {
  bool _isConfig = false;
  String? _widgetId;
  bool _isDataRead = false;
  SharedPreferences? _prefs;

  final GlobalKey<IconDataState> _dataWidgetState = GlobalKey<IconDataState>();

  @override
  void initState() {
    super.initState();
    () async {
      _prefs = await SharedPreferences.getInstance();
      setState(() {});
    }();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as NewIconArguments;
    _isConfig = args.isConfig;
    _widgetId = args.widgetId;
    if (_prefs != null && !_isDataRead) {
      _isDataRead = true;
      setState(() {});
    }
    ReceiveIntent.setResult(kActivityResultCanceled);
    return Scaffold(
      appBar: AppBar(
        title: Text('ICON_NEW_TITLE'.tr()),
        backgroundColor: const Color(0xFFE6DFF1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isConfig ? Icons.close_rounded : Icons.arrow_back,
              color: Colors.black),
          onPressed: () {
            if (_isConfig) {
              SystemNavigator.pop();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                _dataWidgetState.currentState!.saveData().then((value) {
                  if (value) {
                    if (_isConfig) {
                      SystemNavigator.pop();
                    } else {
                      Navigator.pop(context, true);
                    }
                  }
                });
              },
              icon: Icon(Icons.check, size: 26, color: Colors.black),
            ),
          ),
        ],
      ),
      body: _prefs == null
          ? _initLoading()
          : IconDataWidget(key: _dataWidgetState, id: _widgetId, prefs: _prefs),
    );
  }

  Widget _initLoading() {
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
  }

// Future<void> _createAddWidget(String name, String path) async {
//   try {
//     final bool result = await platform
//         .invokeMethod('createWidget', {"name": name, "path": path});
//     if (result != null) {
//       // saveWidgetData(result, name, path).then((value) => SystemNavigator.pop());
//       Navigator.pop(context, true);
//     } else {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.remove("name_new");
//       prefs.remove("path_new");
//       prefs.remove("text_color_new");
//       prefs.remove("type_new");
//     }
//   } on PlatformException catch (e) {}
// }
}
