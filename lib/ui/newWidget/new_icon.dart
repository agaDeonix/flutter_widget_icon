import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class NewIconScreen extends StatefulWidget {
  String? widgetId;

  NewIconScreen(this.widgetId);

  @override
  _NewIconScreenState createState() => _NewIconScreenState();
}

class _NewIconScreenState extends State<NewIconScreen> {
  bool _isConfig = false;
  String _name = "";
  String? _image;
  var _controller = TextEditingController(text: '');
  final ImagePicker _picker = ImagePicker();

  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  String dropdownValue = 'Image';

  static const platform = MethodChannel('samples.flutter.dev/widgets');

  @override
  Widget build(BuildContext context) {
    _isConfig = widget.widgetId != null;
    ReceiveIntent.setResult(kActivityResultCanceled);
    // _id = ModalRoute.of(context)!.settings.arguments as String;
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
        title: Text("New Icon"),
        leading: IconButton(
          icon: Icon(_isConfig ? Icons.close_rounded : Icons.arrow_back, color: Colors.white),
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
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _onComleteClicked();
              },
              child: Icon(
                Icons.check,
                size: 26,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a icon name'),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  Container(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 42,
                        width: 42,
                        color: pickerColor,
                      ),
                    ),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Colors.black),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 16), minimumSize: Size(double.infinity, 44)),
                        onPressed: () => {_pickColor()},
                        child: Text('Text color'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Align(
                alignment: Alignment.topLeft,
                  child: Text(
                "Icon type",
                style: const TextStyle(color: Colors.black45, fontSize: 14),
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: new DropdownButton<String>(
                isExpanded: true,
                value: dropdownValue,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Image', 'Link'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 16), minimumSize: Size(double.infinity, 44)),
                onPressed: () => {_chooseImage()},
                child: Text('Choose image'),
              ),
            ),
            new LayoutBuilder(builder: (context, constraint) {
              return _image == null
                  ? SvgPicture.asset(
                      "assets/images/ic_placeholder.svg",
                      width: constraint.biggest.width,
                    )
                  : Image.file(
                      File(_image!),
                      width: constraint.biggest.width,
                    );
            }),
          ],
        ),
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _chooseImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image!.path;
    });
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          //   showLabel: true, // only on portrait mode
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   pickerColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
          //
          // child: MultipleChoiceBlockPicker(
          //   pickerColors: currentColors,
          //   onColorsChanged: changeColors,
          // ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onComleteClicked() {
    FocusScope.of(context).unfocus();
    if (_name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Container(
          child: Text('Enter name'),
          alignment: AlignmentDirectional.center,
          height: 30,
        )));
      return;
    }
    if (_image == null || _image!.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Container(
          child: Text('Choose image'),
          alignment: AlignmentDirectional.center,
          height: 30,
        )));
      return;
    }
    () async {
      if (widget.widgetId == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("name_new", _name).then((value) => prefs.setString("path_new", _image!).then((value) => _createAddWidget(_name, _image ?? "")));
      } else {
        saveWidgetData(widget.widgetId, _name, _image).then((value) => _setActivityResult());
      }
    }();
  }

  Future<void> _createAddWidget(String name, String path) async {
    try {
      final bool result = await platform.invokeMethod('createWidget', {"name": name, "path": path});
      if (result != null) {
        // saveWidgetData(result, name, path).then((value) => SystemNavigator.pop());
        Navigator.pop(context, true);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove("name_new");
        prefs.remove("path_new");
      }
    } on PlatformException catch (e) {
      //TODO need show message cant create widget
    }
  }

  Future<void> _setActivityResult() async {
    developer.log('created_${widget.widgetId}', name: 'WIDGET');
    HomeWidget.updateWidget(
      name: 'SimpleAppWidget',
      androidName: 'SimpleAppWidget',
      iOSName: 'SimpleAppWidget',
    );
    await ReceiveIntent.setResult(kActivityResultOk).then((value) {
      if (_isConfig) {
        SystemNavigator.pop();
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> saveWidgetData(String? widgetId, String name, String? image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getString("list_ids");
    if (list == null || list.isEmpty) {
      list = widget.widgetId;
    } else {
      list += ",${widget.widgetId}";
    }
    prefs.setString("list_ids", list!);
    return prefs.setString("name_${widget.widgetId}", _name).then((value) => prefs.setString("path_${widget.widgetId}", _image!));
  }
}
