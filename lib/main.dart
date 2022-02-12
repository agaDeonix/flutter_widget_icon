import 'package:flutter/material.dart';
import 'package:widget_icon/ui/colors.style.dart';
import 'package:widget_icon/ui/editWidget/edit_icon.dart';
import 'package:widget_icon/ui/newWidget/new_icon.dart';
import 'package:widget_icon/ui/onboarding/onboarding.view.dart';
import 'package:widget_icon/ui/splash/splash.dart';
import 'package:widget_icon/ui/widgets_list/widgets_list.dart';
import 'package:easy_localization/easy_localization.dart';

import 'utils/Utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: [Locale('en', 'US'), Locale('ru', 'RU')],
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'US'),
        child: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICON WIDGET',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      initialRoute: "/splash",
      routes: {
        '/splash': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/list': (context) => WidgetsListScreen(),
        '/add_new': (context) => NewIconScreen(),
        '/edit': (context) => EditIconScreen(),
      },
      theme: ThemeData(
          primarySwatch: Utils.createMaterialColor(Color(0xFF8B56DD)),
          scaffoldBackgroundColor: CColors.background,
          primaryTextTheme:
              TextTheme(headline6: TextStyle(color: Colors.black))),
    );
  }
}
