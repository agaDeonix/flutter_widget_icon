import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/utils/platform_home_manager.dart';

class IconDataWidget extends StatefulWidget {
  final String? id;

  const IconDataWidget({Key? key, this.id}) : super(key: key);

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

  late HomeWidgetData _homeWidgetData;
  String? _nameError;
  String? _pathError;
  String? _imageError;
  late Color _color;
  var _nameController = TextEditingController(text: '');
  var _linkController = TextEditingController(text: '');
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _homeWidgetData =
        PlatformHomeManager.instance.getHomeWidget(widget.id ?? "");
    _color = fromHex(_homeWidgetData.color) ?? colors.first;
    _nameController = TextEditingController(text: _homeWidgetData.name);
    _linkController = TextEditingController(text: _homeWidgetData.path);
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
                hintText: 'ICON_NAME_HINT'.tr(),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: _nameError),
            onChanged: (value) {
              setState(() {
                _homeWidgetData.name = value;
                _nameError = null;
              });
            },
          ),
          SizedBox(
            height: 25,
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('ICON_CHOOSE_COLOR'.tr(),
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
              child: Text('ICON_TYPE_WIDGET'.tr(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500))),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 15),
            child: new DropdownButtonFormField(
              isExpanded: true,
              value: _homeWidgetData.type,
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
                hintText: 'ICON_NAME_HINT'.tr(),
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _homeWidgetData.type = newValue!;
                });
              },
              items: <String>['Image', 'Link'].map((String value) {
                return new DropdownMenuItem<String>(
                  value: value,
                  child: new Text(value == "Image"
                      ? 'ITEM_TYPE_IMAGE'.tr()
                      : 'ITEM_TYPE_LINK'.tr()),
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
    if (_homeWidgetData.type == "Image") {
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
          child: Text('ICON_IMAGE_CHOOSE'.tr()),
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
        if (_homeWidgetData.path.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: new LayoutBuilder(builder: (context, constraint) {
                return Image.file(
                  File(_homeWidgetData.path),
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
              hintText: 'ICON_URL_HINT'.tr(),
              errorText: _pathError),
          onChanged: (value) {
            setState(() {
              _homeWidgetData.path = value;
              _pathError = null;
            });
          },
        ),
      ],
    );
  }

  void changeColor(Color color) {
    _homeWidgetData.color = '#${color.value.toRadixString(16)}';
    setState(() {
      _color = color;
    });
  }

  List<Widget> _initColors() {
    List<Widget> result = [];
    colors.forEach((element) {
      result.add(GestureDetector(
        onTap: () {
          _homeWidgetData.color = '#${element.value.toRadixString(16)}';
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
      _homeWidgetData.path = image!.path;
      _imageError = null;
    });
  }

  Color? fromHex(String? hexString) {
    if (hexString != null && hexString.isNotEmpty) {
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
    if (_homeWidgetData.name.isEmpty) {
      setState(() {
        _nameError = 'ICON_ERROR_ENTER_NAME'.tr();
      });
      return false;
    }

    if (_homeWidgetData.path.isEmpty) {
      setState(() {
        if (_homeWidgetData.type == "Image") {
          _imageError = 'ICON_ERROR_CHOOSE_IMAGE'.tr();
        } else {
          _pathError = 'ICON_ERROR_ENTER_URL'.tr();
        }
      });
    }
    await saveWidgetData();
    PlatformHomeManager.instance.updateHomeWidgets();
    await _setActivityResult();
    return true;
  }

  Future<void> saveWidgetData() {
    return PlatformHomeManager.instance.saveHomeWidget(_homeWidgetData);
  }

  Future<void> _setActivityResult() {
    return PlatformHomeManager.instance.setConfigResult(_homeWidgetData.id);
  }
}
