import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewIconScreen extends StatefulWidget {
  @override
  _NewIconScreenState createState() => _NewIconScreenState();
}

class _NewIconScreenState extends State<NewIconScreen> {
  String _name = "";
  String? _image;
  var _controller = TextEditingController(text: '');
  final ImagePicker _picker = ImagePicker();

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
        ..showSnackBar(SnackBar(content: Container(child: Text('Enter name'), alignment: AlignmentDirectional.center, height: 30,)));
      return;
    }
    if (_image == null || _image!.isEmpty) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Container(child: Text('Choose image'), alignment: AlignmentDirectional.center, height: 30,)));
      return;
    }
    () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var list = prefs.getStringList("ids") ?? [];
      var last;
      if (list.isEmpty) {
        last = "0";
      } else {
        last = list.last;
      }
      var id = (int.parse(last) + 1).toString();
      list.add(id);
      prefs.setStringList("ids", list);
      prefs.setString("name_$id", _name);
      prefs.setString("path_$id", _image!);
      Navigator.pop(context, true);
    }();
  }

  @override
  Widget build(BuildContext context) {
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
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
                  border: OutlineInputBorder(), hintText: 'Enter a icon name'),
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
}
