import 'package:flutter/material.dart';
import 'package:pmvvm/pmvvm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_icon/utils/constants.dart';

class OnboardingViewModel extends ViewModel {
  var currentPage = 0;

  void nextPage() {
    currentPage++;
    if (currentPage > 2) {
      () async {
        var prefs = await SharedPreferences.getInstance();
        prefs.setBool(Constants.IS_ONBOARDING_SHOWN, true);
        Navigator.pushReplacementNamed(context, "/list");
      }();
    }
    notifyListeners();
  }
}
