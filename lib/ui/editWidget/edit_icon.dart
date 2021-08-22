import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditIconScreen extends StatefulWidget {
  @override
  _EditIconScreenState createState() => _EditIconScreenState();
}

class _EditIconScreenState extends State<EditIconScreen> {
  String _id = "";
  String _name = "";
  String? _image;
  var _controller = TextEditingController(text: '');
  final ImagePicker _picker = ImagePicker();
  SharedPreferences? _prefs;

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
      _prefs?.setString("name_$_id", _name);
      _prefs?.setString("path_$_id", _image!);
      Navigator.pop(context, true);
    }();
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
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
      var list = _prefs!.getStringList("ids") ?? [];
      list.remove(_id);
      _prefs!.setStringList("ids", list);
      _prefs!.remove("name_$_id");
      _prefs!.remove("path_$_id");
      Navigator.pop(context, true);
    }();
  }

  @override
  Widget build(BuildContext context) {
    _id = ModalRoute.of(context)!.settings.arguments as String;
    if (_prefs != null && _image == null) {
      _name = _prefs!.getString("name_$_id") ?? "";
      _image = _prefs!.getString("path_$_id") ?? "";
      _controller = TextEditingController(text: _name);
    }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Edit Icon"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
                    controller: _controller,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a icon name'),
                    onChanged: (value) {
                      setState(() {
                        _name = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 16),
                          minimumSize: Size(double.infinity, 44)),
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
                  })
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
}
