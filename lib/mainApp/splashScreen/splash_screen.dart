import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants/assets_constants.dart';
import '../network/no_internet.dart';
import '../onboarding/onboarding_screen.dart';
import '../../reusable/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<NetworkBloc>().add(NetworkObserve());
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
