import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/utils/StringConstants.dart';

class IconDataWidget extends StatefulWidget {
  final String? id;
  final SharedPreferences? prefs;

  const IconDataWidget({Key? key, this.id, this.prefs}) : super(key: key);

  @override
  IconDataState createState() => IconDataState();
}

class IconDataState extends State<IconDataWidget> {
  static List<Color> colors = [
    Colors.black,
    Colors.white,
    Colors.grey,
    Colors.blue,
    Colors.deepOrange,
    Colors.lightGreen
  ];

  String _id = "";
  String _name = "";
  String? _nameError;
  String? _path;
  String? _pathError;
  String? _image;
  String? _imageError;
  String _type = "Image";
  late Color _color;
  var _nameController = TextEditingController(text: '');
  var _linkController = TextEditingController(text: '');
  final ImagePicker _picker = ImagePicker();
  late SharedPreferences _prefs;

  static const platform = MethodChannel('samples.flutter.dev/widgets');

  @override
  void initState() {
    super.initState();
    _id = widget.id ?? "";
    _prefs = widget.prefs!;
    _name = _prefs.getString("name_$_id") ?? "";
    _type = (int.parse(_prefs.getString("type_$_id") ?? "0")) == 0
        ? "Image"
        : "Link";
    if (_type == "Image") {
      _image = _prefs.getString("path_$_id") ?? "";
    } else {
      _path = _prefs.getString("path_$_id") ?? "";
    }
    _color = fromHex(_prefs.getString("text_color_$_id")) ?? colors.first;
    _nameController = TextEditingController(text: _name);
    _linkController = TextEditingController(text: _path);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
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
          Align(
              alignment: Alignment.centerLeft,
              child: Text(Strings.ICON_CHOOSE_COLOR,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500))),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 25),
            child: Row(
              children: _initColors(),
            ),
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text(Strings.ICON_TYPE_WIDGET,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500))),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 15),
            child: new DropdownButtonFormField(
              isExpanded: true,
              value: _type,
              elevation: 10,
              iconEnabledColor: Color(0xff8B56DD),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.only(
                    left: 14.0, bottom: 8.0, top: 8.0, right: 14),
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
                  _type = newValue!;
                });
              },
              items: <String>['Image', 'Link'].map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value == "Image"
                      ? Strings.ITEM_TYPE_IMAGE
                      : Strings.ITEM_TYPE_LINK),
                );
              }).toList(),
            ),
          ),
          initLayoutByType()
        ],
      ),
    ));
  }

  Widget initLayoutByType() {
    if (_type == "Image") {
      return initPhoto();
    } else {
      return initLink();
    }
  }

  Widget initPhoto() {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
              minimumSize: Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
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
        if (_image != null && _image!.isNotEmpty)
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
              contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
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
    setState(() => _color = color);
  }

  List<Widget> _initColors() {
    List<Widget> result = [];
    colors.forEach((element) {
      result.add(GestureDetector(
        onTap: () {
          setState(() {
            _color = element;
          });
        },
        child: Container(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(_color.value == element.value ? 8 : 10),
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
          decoration: _color.value == element.value
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

  Future<void> _chooseImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image!.path;
      _imageError = null;
    });
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

  Future<bool> saveData() async {
    FocusScope.of(context).unfocus();
    if (_name.isEmpty) {
      setState(() {
        _nameError = Strings.ICON_ERROR_ENTER_NAME;
      });
      return false;
    }
    if (_type == "Image") {
      if (_image == null || _image!.isEmpty) {
        setState(() {
          _imageError = Strings.ICON_ERROR_CHOOSE_IMAGE;
        });
        return false;
      }
      var textColor = '#${_color.value.toRadixString(16)}';
      await saveWidgetData(_id, _name, textColor, 0, _image!);
      HomeWidget.updateWidget(
          name: 'SimpleAppWidget',
          androidName: 'SimpleAppWidget',
          iOSName: 'SimpleAppWidget');
      await _setActivityResult();
      return true;
    } else {
      if (_path == null || _path!.isEmpty) {
        _pathError = Strings.ICON_ERROR_ENTER_URL;
        return false;
      }
      var textColor = '#${_color.value.toRadixString(16)}';
      await saveWidgetData(_id, _name, textColor, 1, _path!);
      HomeWidget.updateWidget(
          name: 'SimpleAppWidget',
          androidName: 'SimpleAppWidget',
          iOSName: 'SimpleAppWidget');
      await _setActivityResult();
      return true;
    }
  }

  Future<void> saveWidgetData(String widgetId, String name, String textColor,
      int type, String path) async {
    var list = _prefs.getString("list_ids");
    if (list == null || list.isEmpty) {
      list = widgetId;
    } else {
      if (!list.contains(widgetId)) {
        list += ",${widgetId}";
      }
    }
    _prefs.setString("list_ids", list);
    return _prefs
        .setBool("deleted_$widgetId", false)
        .then((value) => _prefs.setString("name_${widgetId}", name))
        .then((value) => _prefs.setString("text_color_${widgetId}", textColor))
        .then((value) => _prefs.setString("type_${widgetId}", type.toString()))
        .then((value) => _prefs.setString("path_${widgetId}", path));
  }

  Future<void> _setActivityResult() async {
    await platform.invokeMethod('setConfigResult', {"id": _id});
  }
}
