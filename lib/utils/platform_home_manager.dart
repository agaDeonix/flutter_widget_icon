import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/utils/constants.dart';
import 'package:widget_icon/utils/platform_home_manager_android.dart';
import 'package:widget_icon/utils/platform_home_manager_ios.dart';

enum Screen { NEW_ICON, EDIT_ICON, LIST, ONBOARDING }

class StartState {
  Screen screen;
  String? widgetId;

  StartState(this.screen, this.widgetId);
}

class HomeWidgetData {
  String id;
  String name;
  String path;
  String type;
  String color;

  HomeWidgetData(this.id, this.name, this.path, this.color, this.type);
}

abstract class PlatformHomeManager {
  static const platform = MethodChannel('samples.flutter.dev/widgets');

  MethodChannel getPlatform() => platform;

  static PlatformHomeManager? _instance;

  static PlatformHomeManager get instance {
    if (Platform.isAndroid) {
      _instance ??= PlatformHomeManagerAndroid();
      return _instance!;
    }
    if (Platform.isIOS) {
      _instance ??= PlatformHomeManagerIos();
      return _instance!;
    }
    throw Exception("Platform ${Platform.operatingSystem} doesn't support.");
  }

  Future<bool?> updateHomeWidgets() {
    return HomeWidget.updateWidget(
      name: 'SimpleAppWidget',
      androidName: 'SimpleAppWidget',
      iOSName: 'SimpleAppWidget',
    );
  }

  Future<void> setConfigResult(String id);

  void sendResultCanceled();

  Future<List<HomeWidgetData>> getHomeWidgetsLists();

  HomeWidgetData getHomeWidget(String id);

  Future<void> saveHomeWidget(HomeWidgetData homeWidgetData);

  Future<StartState> initStartState(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    var isOnboardingShown =
        prefs.getBool(Constants.IS_ONBOARDING_SHOWN) ?? false;
    if (!isOnboardingShown) {
      return StartState(Screen.ONBOARDING, null);
    } else {
      return StartState(Screen.LIST, null);
    }
  }
}
