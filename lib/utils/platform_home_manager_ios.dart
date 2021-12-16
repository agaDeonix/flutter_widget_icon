import 'package:widget_icon/utils/platform_home_manager.dart';

class PlatformHomeManagerIos extends PlatformHomeManager {
  Future<void> setConfigResult(String id) {
    return Future.value();
  }

  void sendResultCanceled() {}

  Future<List<HomeWidgetData>> getHomeWidgetsLists() {
    return Future.value([]);
  }

  HomeWidgetData getHomeWidget(String id) {
    return HomeWidgetData(id, "NONE", "", "", "0");
  }

  Future<void> saveHomeWidget(HomeWidgetData homeWidgetData) async {
    return Future.value();
  }
}
