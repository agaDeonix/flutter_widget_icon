import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:widget_icon/ui/editWidget/edit_icon.dart';
import 'package:widget_icon/utils/platform_home_manager.dart';
import 'package:widget_icon/utils/utils.dart';

import '../colors.style.dart';

class WidgetsListScreen extends StatefulWidget {
  @override
  _WidgetsListScreenState createState() => _WidgetsListScreenState();
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    required this.resumeCallBack,
    required this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await suspendingCallBack();
        break;
    }
  }
}

class _WidgetsListScreenState extends State<WidgetsListScreen> {
  @override
  void initState() {
    super.initState();
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        setState(() {});
      }
    });
    PlatformHomeManager.instance.updateHomeWidgets();
  }

  // void _addNew() {
  //   Navigator.pushNamed(context, '/add_new',
  //           arguments: NewIconArguments(null, false))
  //       .then((value) {
  //     setState(() {});
  //   });
  // }

  void _editItem(String id) {
    Navigator.pushNamed(context, '/edit',
            arguments: EditIconArguments(id, false))
        .then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("WIDGETS".tr()),
          backgroundColor: CColors.background,
          elevation: 0,
        ),
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: FutureBuilder<List<HomeWidgetData>>(
          future: PlatformHomeManager.instance.getHomeWidgetsLists(),
          builder: (context, AsyncSnapshot<List<HomeWidgetData>> snapshot) {
            if (snapshot.hasData) {
              return (snapshot.data!.isEmpty
                  ? _initEmpty()
                  : _initList(snapshot.data!));
            } else {
              return _initLoading();
            }
          },
        )),
        floatingActionButton: FutureBuilder<List<HomeWidgetData>>(
          future: PlatformHomeManager.instance.getHomeWidgetsLists(),
          builder: (context, AsyncSnapshot<List<HomeWidgetData>> snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return initFloatingActionButton();
            } else {
              return SizedBox();
            }
          },
        ));
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
            valueColor: new AlwaysStoppedAnimation<Color>(
                Utils.createMaterialColor(Color(0xFF8B56DD))),
          ),
        ),
      ],
    );
  }

  Widget _initEmpty() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("assets/images/ic_empty_help.png"),
        fit: BoxFit.scaleDown,
      )),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text('EMPTY_TITLE'.tr(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.bold))),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text('EMPTY_MESSAGE'.tr(),
                  textAlign: TextAlign.left,
                  style: const TextStyle(color: Colors.black54, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initList(List<HomeWidgetData> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _initItem(list[index], index == 0, index == list.length - 1);
      },
    );
  }

  Widget _initItem(HomeWidgetData homeWidgetData, bool isFirst, bool isLast) {
    var id = homeWidgetData.id;
    var name = homeWidgetData.name;
    var path = homeWidgetData.path;
    var type = int.parse(homeWidgetData.type);
    var typeText = 'ITEM_TYPE_IMAGE'.tr();
    if (type == 1) {
      typeText = 'ITEM_TYPE_LINK'.tr();
    }
    return GestureDetector(
      onTap: () => _editItem(id),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.fromLTRB(10, isFirst ? 10 : 5, 10, isLast ? 10 : 5),
        elevation: 10,
        shadowColor: Color(0x80000000),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              getImageByType(type, path),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text(
                        'ITEM_TYPE'.tr(args: [typeText]),
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Color(0xff8B56DD),
                size: 35.0,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getImageByType(int type, String path) {
    if (type == 0) {
      return Image.file(File(path), width: 50, height: 50, fit: BoxFit.cover);
    } else {
      return Image.asset("assets/images/ic_url.png",
          width: 50, height: 50, fit: BoxFit.cover);
    }
  }

  Widget initFloatingActionButton() {
    return FloatingActionButton.extended(
      label: Text('LIST_ADD_WIDGET'.tr()),
      icon: const Icon(Icons.add),
      backgroundColor: Color(0xff8B56DD),
      onPressed: () {
        _showHowAddHomeScreenWidget();
      },
    );
  }

  void _showHowAddHomeScreenWidget() {
    showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('LIST_HOW_ADD_WIDGET_TITLE'.tr()),
              content: Text("EMPTY_MESSAGE".tr()),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'LIST_HOW_ADD_WIDGET_OK'.tr(),
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            )).then((value) {});
  }
}
