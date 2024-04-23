import 'package:flutter/material.dart';
import 'package:video_call_app/mainApp/auth/signIn/sign_in_screen.dart';

import '../services/auth_services.dart';
import 'buttons.dart';
import 'colors.dart';
import 'navigator.dart';
import 'sized_box_hw.dart';

class CustomAlertDialog extends StatelessWidget {
  final void Function()? onConfirm;
  final String title;
  final String message;

  const CustomAlertDialog({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        title,
        style: const TextStyle(color: red),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: bgColor),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            'Logout',
            style: TextStyle(color: red),
          ),
        ),
      ],
    );
  }
}

void showLogoutConfirmationDialog(BuildContext context, AuthenticationService auth) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Logout !',
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          CustomOutlinedButton(
            isLogout: false,
            title: 'Cancel',
            action: () {
              removeScreen(context);
            },
          ),
          sw12,
          CustomOutlinedButton(
            title: 'Logout',
            action: () async {
              removeScreen(context);
              pushByRemovingAll(context, const SignIn());
              await auth.signOut(context);
            },
          ),
          sw12
        ],
      );
    },
  );
}
