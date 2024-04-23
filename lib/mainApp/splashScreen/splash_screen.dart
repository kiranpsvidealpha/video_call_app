import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../reusables/assets_constants.dart';
import '../../reusables/colors.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Container(
        width: screenWidth,
        decoration: const BoxDecoration(gradient: primaryColor),
        child: Center(
          child: SvgPicture.asset(
            AssetsConstants.appLogo,
            width: 250,
          ),
        ),
      ),
    );
  }
}
