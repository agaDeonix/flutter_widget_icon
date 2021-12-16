import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_intent/receive_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/utils/platform_home_manager.dart';

import 'constants.dart';

class PlatformHomeManagerAndroid extends PlatformHomeManager {
  late SharedPreferences _prefs;

  Future<StartState> initStartState(BuildContext context) async {
    var isNewValue = false;
    var isEditValue = false;
    String? widgetId;
    _prefs = await SharedPreferences.getInstance();
    try {
      final receivedIntent = await ReceiveIntent.getInitialIntent();
      if (receivedIntent != null &&
          receivedIntent.action ==
              "android.appwidget.action.APPWIDGET_CONFIGURE") {
        widgetId = receivedIntent.extra!["appWidgetId"].toString();
        var widgetName = _prefs.getString("name_$widgetId") ?? "";
        var widgetPath = _prefs.getString("path_$widgetId") ?? "";
        if (widgetName.isNotEmpty && widgetPath.isNotEmpty) {
          isEditValue = true;
        } else {
          isNewValue = true;
        }
      }
    } on PlatformException {}
    if (isNewValue) {
      return StartState(Screen.NEW_ICON, widgetId);
    } else if (isEditValue) {
      return StartState(Screen.EDIT_ICON, widgetId);
    } else {
      return super.initStartState(context);
    }
  }

  Future<void> setConfigResult(String id) {
    return getPlatform().invokeMethod('setConfigResult', {"id": id});
  }

  void sendResultCanceled() {
    ReceiveIntent.setResult(kActivityResultCanceled);
  }

  void reloadIfNeed(Function onComplete) {
    _prefs.reload().then((value) {
      onComplete();
    });
  }

  Future<List<HomeWidgetData>> getHomeWidgetsLists() {
    return _prefs.reload().then((value) {
      var ids = _prefs
              .getString("list_ids")
              ?.split(",")
              .where((element) => element.isNotEmpty)
              .toList() ??
          List.empty();
      List<HomeWidgetData> result = [];
      for (var id in ids) {
        result.add(HomeWidgetData(
            id,
            _prefs.getString("name_$id") ?? "",
            _prefs.getString("path_$id") ?? "",
            _prefs.getString("text_color_$id") ?? "",
            _prefs.getString("type_$id") ?? "0"));
      }
      return result;
    });
  }

  HomeWidgetData getHomeWidget(String id) {
    var name = _prefs.getString("name_$id") ?? "";
    var type = (int.parse(_prefs.getString("type_$id") ?? "0")) == 0
        ? "Image"
        : "Link";
    var path = "";
    if (type == "Image") {
      path = _prefs.getString("path_$id") ?? "";
    } else {
      path = _prefs.getString("path_$id") ?? "";
    }
    var color = _prefs.getString("text_color_$id") ?? "";

    return HomeWidgetData(id, name, path, color, type);
  }

  Future<void> saveHomeWidget(HomeWidgetData homeWidgetData) async {
    var list = _prefs.getString("list_ids");
    if (list == null || list.isEmpty) {
      list = homeWidgetData.id;
    } else {
      if (!list.contains(homeWidgetData.id)) {
        list += ",${homeWidgetData.id}";
      }
    }
    _prefs.setString("list_ids", list);
    return _prefs
        .setString("name_${homeWidgetData.id}", homeWidgetData.name)
        .then((value) => _prefs.setString(
            "text_color_${homeWidgetData.id}", homeWidgetData.color))
        .then((value) => _prefs.setString("type_${homeWidgetData.id}",
            (homeWidgetData.type == "Image") ? "0" : "1"))
        .then((value) =>
            _prefs.setString("path_${homeWidgetData.id}", homeWidgetData.path))
        .then((value) => _prefs.reload());
  }
}
