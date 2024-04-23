import 'package:flutter/material.dart';

import 'colors.dart';

showSnackBar(BuildContext context, String title, {bool error = false}) {
  //Create a snackbar to show in the scaffold with custom message
  final snackBar = SnackBar(
    backgroundColor: error ? red : blue,
    duration: Duration(seconds: error ? 3 : 1),
    content: Text(
      title, //this is the text that will be visible to the user
      style: const TextStyle(color: white),
    ),
    action: SnackBarAction(
      label: "OK",
      textColor: white,
      onPressed: () {
        //hide the current snackBar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );
  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

void closeAllDialogs(BuildContext context) {
  Navigator.of(context, rootNavigator: true).popUntil((route) => route is! PopupRoute);
}
