import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widget_icon/ui/base/icon_data.dart';

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

  final GlobalKey<IconDataState> _dataWidgetState = GlobalKey<IconDataState>();

  void _onRemoveClicked(String id) {
    showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('ICON_DELETE_TITLE'.tr()),
              content: Text('ICON_DELETE_MESSAGE'.tr()),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('ICON_DELETE_OK'.tr()),
                ),
              ],
            )).then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as EditIconArguments;
    _isConfig = args.isConfig;
    var id = args.widgetId ?? "";

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('ICON_EDIT_TITLE'.tr()),
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
          IconButton(
            onPressed: () {
              _onRemoveClicked(id);
            },
            icon: Icon(Icons.delete_forever_outlined,
                size: 26, color: Colors.black),
          ),
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
      body: IconDataWidget(key: _dataWidgetState, id: id),
    );
  }
}
