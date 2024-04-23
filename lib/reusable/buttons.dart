import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'colors.dart';

class ColouredElevatedButton extends StatelessWidget {
  const ColouredElevatedButton({super.key, required this.onCLick, required this.title});
  final Function() onCLick;
  final String title;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: onCLick,
      child: Container(
        decoration: const BoxDecoration(
          gradient: primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        width: size.width,
        height: size.height / 8,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class LogoedElevatedButton extends StatelessWidget {
  const LogoedElevatedButton({
    super.key,
    required this.onCLick,
    required this.title,
    required this.svg,
  });
  final Function() onCLick;
  final String title;
  final String svg;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: white,
        ),
        onPressed: onCLick,
        child: Container(
          height: 48,
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 25,
                child: SvgPicture.asset(
                  "assets/images/$svg.svg",
                  height: 25,
                  width: 25,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    this.action,
    required this.title,
    this.isLogout = true,
  });
  final String title;
  final bool? isLogout;
  final void Function()? action;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: transparent,
        side: BorderSide(color: isLogout! ? red : green),
        textStyle: const TextStyle(fontSize: 16),
        padding: const EdgeInsets.all(16),
      ),
      child: Text(
        title,
        style: TextStyle(color: isLogout! ? red : green),
      ),
    );
  }
}
