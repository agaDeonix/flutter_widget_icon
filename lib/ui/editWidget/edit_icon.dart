import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/utils/StringConstants.dart';

class EditIconScreen extends StatefulWidget {
  const EditIconScreen({Key? key}) : super(key: key);

  @override
  _EditIconScreenState createState() => _EditIconScreenState();
}

class EditIconArguments {
  String? widgetId;
  bool isConfig;

  EditIconArguments(this.widgetId, this.isConfig);
}

class _EditIconScreenState extends State<EditIconScreen> {
  bool _isConfig = false;
  String _id = "";
  String _name = "";
  String? _nameError;
  String? _path;
  String? _pathError;
  String? _image;
  String? _imageError;
  var _nameController = TextEditingController(text: '');
  var _linkController = TextEditingController(text: '');
  final ImagePicker _picker = ImagePicker();
  SharedPreferences? _prefs;

  static List<Color> colors = [Colors.black, Colors.white, Colors.grey, Colors.blue, Colors.deepOrange, Colors.lightGreen];

  // create some values
  Color pickerColor = colors.first;

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
      _imageError = null;
    });
  }

  void _onComleteClicked() {
    FocusScope.of(context).unfocus();
    if (_name.isEmpty) {
      setState(() {
        _nameError = Strings.ICON_ERROR_ENTER_NAME;
      });
      return;
    }
    var textColor = '#${pickerColor.value.toRadixString(16)}';
    if (dropdownValue == "Image") {
      if (_image == null || _image!.isEmpty) {
        _imageError = Strings.ICON_ERROR_CHOOSE_IMAGE;
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
        _pathError = Strings.ICON_ERROR_ENTER_URL;
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
              title: const Text(Strings.ICON_DELETE_TITLE),
              content: const Text(Strings.ICON_DELETE_MESSAGE),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(Strings.ICON_DELETE_OK),
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

  Color? fromHex(String? hexString) {
    if (hexString != null) {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as EditIconArguments;
    _isConfig = args.isConfig;
    _id = args.widgetId ?? "";

    if (_prefs != null && _image == null && _path == null) {
      _name = _prefs!.getString("name_$_id") ?? "";
      dropdownValue = (int.parse(_prefs!.getString("type_$_id") ?? "0")) == 0 ? "Image" : "Link";
      if (dropdownValue == "Image") {
        _image = _prefs!.getString("path_$_id") ?? "";
      } else {
        _path = _prefs!.getString("path_$_id") ?? "";
      }
      // currentColor = fromHex(_prefs!.getString("text_color_$_id") ?? "#ffffffff");
      // pickerColor = currentColor;
      pickerColor = fromHex(_prefs!.getString("text_color_$_id")) ?? colors.first;
      _nameController = TextEditingController(text: _name);
      _linkController = TextEditingController(text: _path);
      setState(() {});
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(Strings.ICON_EDIT_TITLE),
        backgroundColor: const Color(0xFFE6DFF1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isConfig ? Icons.close_rounded : Icons.arrow_back, color: Colors.black),
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
              child: Icon(Icons.delete_forever_outlined, size: 26, color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _onComleteClicked();
              },
              child: Icon(Icons.check, size: 26, color: Colors.black),
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
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: Strings.ICON_NAME_HINT,
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        errorText: _nameError),
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                        _nameError = null;
                      });
                    },
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text(Strings.ICON_CHOOSE_COLOR, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500))),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 25),
                    child: Row(
                      children: _initColors(),
                    ),
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text(Strings.ICON_TYPE_WIDGET, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500))),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 15),
                    child: new DropdownButtonFormField(
                      isExpanded: true,
                      value: dropdownValue,
                      elevation: 10,
                      iconEnabledColor: Color(0xff8B56DD),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0, right: 14),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: Strings.ICON_NAME_HINT,
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String>['Image', 'Link'].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value == "Image" ? Strings.ITEM_TYPE_IMAGE : Strings.ITEM_TYPE_LINK),
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 16), minimumSize: Size(double.infinity, 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          onPressed: () => {_chooseImage()},
          child: Text(Strings.ICON_IMAGE_CHOOSE),
        ),
        if (_imageError != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Text(
                _imageError!,
                style: TextStyle(color: Color(0xffd50000), fontSize: 12),
              ),
            ),
          ),
        if (_image != null)
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: new LayoutBuilder(builder: (context, constraint) {
                return Image.file(
                  File(_image!),
                  width: constraint.biggest.width,
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget initLink() {
    return Column(
      children: [
        TextField(
          controller: _linkController,
          decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: Strings.ICON_URL_HINT,
              errorText: _pathError),
          onChanged: (value) {
            setState(() {
              _path = value;
              _pathError = null;
            });
          },
        ),
      ],
    );
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  List<Widget> _initColors() {
    List<Widget> result = [];
    colors.forEach((element) {
      result.add(GestureDetector(
        onTap: () {
          setState(() {
            pickerColor = element;
          });
        },
        child: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(pickerColor.value == element.value ? 8 : 10),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 50,
                width: 50,
                color: element,
              ),
            ),
          ),
          width: 50,
          height: 50,
          decoration: pickerColor.value == element.value
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 3,
                    color: Color(0xff8B56DD),
                  ))
              : null,
        ),
      ));
      if (colors.last != element) {
        result.add(
          Expanded(
            child: SizedBox(
              width: 1,
            ),
          ),
        );
      }
    });

    return result;
  }
}
