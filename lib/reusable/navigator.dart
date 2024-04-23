import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<dynamic> pushSimple(Widget newScreen) {
  return Get.to(() => newScreen, transition: Transition.rightToLeft)!;
}

void removeScreen(BuildContext context) {
  return Navigator.of(context).pop();
}

Future<dynamic> pushByRemovingAll(BuildContext context, Widget newScreen) {
  return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => newScreen), (Route<dynamic> route) => false);
}
