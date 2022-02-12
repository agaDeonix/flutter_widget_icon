import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pmvvm/mvvm_builder.widget.dart';
import 'package:pmvvm/pmvvm.dart';
import 'package:widget_icon/ui/colors.style.dart';
import 'package:widget_icon/ui/onboarding/onboarding.vm.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MVVM<OnboardingViewModel>(
      view: (context, vmodel) => _OnboardinggView(),
      viewModel: OnboardingViewModel(),
    );
  }
}

class _OnboardinggView extends StatelessView<OnboardingViewModel> {
  const _OnboardinggView({Key? key}) : super(key: key, reactive: true);

  @override
  Widget render(BuildContext context, OnboardingViewModel viewModel) {
    return Scaffold(
        body: Container(
      color: CColors.background,
      child: getPages(viewModel),
    ));
  }

  Widget getPages(OnboardingViewModel viewModel) {
    switch (viewModel.currentPage) {
      case 0:
        {
          return getFirstPage(viewModel);
        }
      case 1:
        {
          return getSecondPage(viewModel);
        }
      case 2:
        {
          return getThirdPage(viewModel);
        }
      default:
        {
          return Container();
        }
    }
  }

  Widget getFirstPage(OnboardingViewModel viewModel) {
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
                  onPressed: viewModel.nextPage,
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

  Widget getSecondPage(OnboardingViewModel viewModel) {
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
                  onPressed: viewModel.nextPage,
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

  Widget getThirdPage(OnboardingViewModel viewModel) {
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
                    onPressed: viewModel.nextPage,
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
