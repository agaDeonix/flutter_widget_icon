import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditIconScreen extends StatefulWidget {
  String? widgetId;

  EditIconScreen(this.widgetId);

  @override
  _EditIconScreenState createState() => _EditIconScreenState();
}

class _EditIconScreenState extends State<EditIconScreen> {
  bool _isConfig = false;
  String _id = "";
  String _name = "";
  String? _path;
  String? _image;
  var _nameController = TextEditingController(text: '');
  var _linkController = TextEditingController(text: '');
  final ImagePicker _picker = ImagePicker();
  SharedPreferences? _prefs;

  // create some values
  Color pickerColor = Colors.black;
  Color currentColor = Colors.black;

  String dropdownValue = 'Image';

  @override
  void initState() {
    super.initState();
    () async {
      _prefs = await SharedPreferences.getInstance();
      setState(() {});
    }();
  }

  Future<void> _chooseImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image!.path;
    });
  }

  void _onComleteClicked() {
    FocusScope.of(context).unfocus();
    if (_name.isEmpty) {
      _showError('Enter name');
      return;
    }
    var textColor = '#${pickerColor.value.toRadixString(16)}';
    if (dropdownValue == "Image") {
      if (_image == null || _image!.isEmpty) {
        _showError('Choose image');
        return;
      }
      () async {
        saveWidgetData(_id, _name, textColor, 0, _image!).then((value) {
          HomeWidget.updateWidget(
            name: 'SimpleAppWidget',
            androidName: 'SimpleAppWidget',
            iOSName: 'SimpleAppWidget',
          );
          if (_isConfig) {
            SystemNavigator.pop();
          } else {
            Navigator.pop(context, true);
          }
        });
      }();
    } else {
      if (_path == null || _path!.isEmpty) {
        _showError('Enter URL');
        return;
      }
      () async {
        saveWidgetData(_id, _name, textColor, 1, _path!).then((value) {
          HomeWidget.updateWidget(
            name: 'SimpleAppWidget',
            androidName: 'SimpleAppWidget',
            iOSName: 'SimpleAppWidget',
          );
          if (_isConfig) {
            SystemNavigator.pop();
          } else {
            Navigator.pop(context, true);
          }
        });
      }();
    }
  }

  Future<void> saveWidgetData(String widgetId, String name, String textColor, int type, String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool("deleted_$_id", false).then((value) => prefs.setString("name_${widgetId}", name)).then((value) => prefs.setString("text_color_${widgetId}", textColor)).then((value) => prefs.setString("type_${widgetId}", type.toString())).then((value) => prefs.setString("path_${widgetId}", path));
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Container(
        child: Text(error),
        alignment: AlignmentDirectional.center,
        height: 30,
      )));
  }

  void _onRemoveClicked() {
    showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Deleting icon'),
              content: const Text('Are you sure?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => _remove(),
                  child: const Text('Yes'),
                ),
              ],
            )).then((value) {
      if (value ?? false) {
        _remove();
      }
    });
  }

  void _remove() {
    () async {
      var list = _prefs!.getString("list_ids")?.split(",") ?? [];
      list.remove(_id);
      _prefs!.setString("list_ids", list.join(","));
      _prefs!.remove("name_$_id");
      _prefs!.remove("path_$_id");
      _prefs!.remove("text_color_$_id");
      _prefs!.remove("type_$_id");
      _prefs!.setBool("deleted_$_id", true);

      HomeWidget.updateWidget(
        name: 'SimpleAppWidget',
        androidName: 'SimpleAppWidget',
        iOSName: 'SimpleAppWidget',
      );

      Navigator.pop(context, true);
    }();
  }

  Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    _isConfig = widget.widgetId != null;
    if (_isConfig) {
      _id = widget.widgetId!;
    } else {
      _id = ModalRoute.of(context)!.settings.arguments as String;
    }
    if (_prefs != null && _image == null && _path == null) {
      _name = _prefs!.getString("name_$_id") ?? "";
      dropdownValue = (int.parse(_prefs!.getString("type_$_id") ?? "0")) == 0 ? "Image" : "Link";
      if (dropdownValue == "Image") {
        _image = _prefs!.getString("path_$_id") ?? "";
      } else {
        _path = _prefs!.getString("path_$_id") ?? "";
      }
      currentColor = fromHex(_prefs!.getString("text_color_$_id") ?? "#ffffffff");
      pickerColor = currentColor;
      _nameController = TextEditingController(text: _name);
      _linkController = TextEditingController(text: _path);
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Edit Icon"),
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
                _onRemoveClicked();
              },
              child: Icon(
                Icons.delete_forever_outlined,
                size: 26,
              ),
            ),
          ),
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
        child: _prefs == null
            ? _initLoading()
            : Column(
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
                children: <Widget>[
                  TextField(
                    controller: _nameController,
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
                  initLayoutByType()
                ],
              ),
      )), // This trailing comma makes auto-formatting nicer for build methods.
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

  Widget initLayoutByType() {
    if (dropdownValue == "Image") {
      return initPhoto();
    } else {
      return initLink();
    }
  }

  Widget initPhoto() {
    return Column(
      children: [
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
    );
  }

  Widget initLink() {
    return Column(
      children: [
        TextField(
          controller: _linkController,
          decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter URL'),
          onChanged: (value) {
            setState(() {
              _path = value;
            });
          },
        ),
      ],
    );
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
}
