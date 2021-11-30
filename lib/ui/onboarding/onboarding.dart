import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/utils/Constants.dart';

import 'package:easy_localization/easy_localization.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Color.fromARGB(255, 230, 223, 241),
      child: getPages(),
    ));
  }

  Widget getPages() {
    switch (_currentPage) {
      case 0:
        {
          return getFirstPage();
        }
      case 1:
        {
          return getSecondPage();
        }
      case 2:
        {
          return getThirdPage();
        }
      default:
        {
          return Container();
        }
    }
  }

  Widget getFirstPage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/ic_onboarding_first_number.png"),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 60),
                child: Text(
                  'ONBOARDING_FIRST_TITLE'.tr().toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xff8B56DD),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset("assets/images/ic_onboarding_first.png"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    setState(() {
                      _currentPage++;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'ONBOARDING_NEXT'.tr().toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getSecondPage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/ic_onboarding_second_number.png"),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 60),
                child: Text(
                  'ONBOARDING_SECOND_TITLE'.tr().toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xff8B56DD),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset("assets/images/ic_onboarding_second.png"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    setState(() {
                      _currentPage++;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('ONBOARDING_NEXT'.tr().toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getThirdPage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/ic_onboarding_third_number.png"),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 60),
                child: Text(
                  'ONBOARDING_THIRD_TITLE'.tr().toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xff8B56DD),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset("assets/images/ic_onboarding_third.png"),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      () async {
                        var prefs = await SharedPreferences.getInstance();
                        setState(() {
                          prefs.setBool(Constants.IS_ONBOARDING_SHOWN, true);
                          Navigator.pushReplacementNamed(context, "/list");
                        });
                      }();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('ONBOARDING_CLOSE'.tr().toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
