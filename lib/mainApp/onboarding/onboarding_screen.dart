import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

import '../appPermissions/permissions_screen.dart';
import '../../constants/assets_constants.dart';
import '../../reusable/colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntroductionScreen(
        globalBackgroundColor: bgColor,
        pages: [
          PageViewModel(
              title: 'Private Chat',
              body: 'Welcome to a secure private chat',
              image: SvgPicture.asset(
                AssetsConstants.appLogo,
                fit: BoxFit.scaleDown,
                width: 250,
              ),
              decoration: introPageDecoration()),
          PageViewModel(
            title: 'Features',
            body: 'We provides all chat features',
            image: buildImage(AssetsConstants.features),
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: 'Simple UI',
            body: 'For enhanced chating experience',
            image: buildImage(AssetsConstants.simpleUI),
            decoration: getPageDecoration(),
          ),
          PageViewModel(
            title: 'Secured',
            body: 'We provide secured chat app',
            image: buildImage(AssetsConstants.secure),
            decoration: getPageDecoration(),
          ),
        ],
        done: const Text(
          'Continue',
          style: TextStyle(color: white, fontSize: 12),
        ),
        onDone: (() {
          appPermissionsNavigate(context);
        }),
        showSkipButton: true,
        skip: const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Skip',
            style: TextStyle(color: white),
          ),
        ),
        onSkip: (() {
          appPermissionsNavigate(context);
        }),
        next: const Text(
          "Next",
          style: TextStyle(color: white),
        ),
        dotsDecorator: getDotDecoration(),
        dotsFlex: 2,
      ),
    );
  }

  void appPermissionsNavigate(context) => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppPermissions()),
      );

  Widget buildImage(String path) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Image.asset(
              path,
              height: 250,
              fit: BoxFit.scaleDown,
            ),
          ),
        ],
      );
  // decotare dote for onboarding
  DotsDecorator getDotDecoration() => DotsDecorator(
        color: grey,
        activeColor: white,
        size: const Size(10, 10),
        activeSize: const Size(22, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      );
  // decorations for onboarding
  PageDecoration getPageDecoration() => const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 16),
        imagePadding: EdgeInsets.all(24),
        pageColor: white,
      );
  PageDecoration introPageDecoration() => const PageDecoration(
        boxDecoration: BoxDecoration(gradient: primaryColor),
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: white),
        bodyTextStyle: TextStyle(color: white),
        imagePadding: EdgeInsets.all(24),
      );
}
