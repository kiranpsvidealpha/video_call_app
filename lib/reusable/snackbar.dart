import 'package:flutter/material.dart';

import 'colors.dart';

showSnackBar(BuildContext context, String title, {required bool error}) {
  final snackBar = SnackBar(
    backgroundColor: error ? red : green,
    duration: Duration(seconds: error ==true? 3 : 1),
    content: Text(
      title,
    ),
    action: SnackBarAction(
      label: 'OK',
      textColor: white,
      onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    ),
  );
  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
