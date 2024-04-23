import 'package:flutter/material.dart';

import 'signIn/sign_in_screen.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  AuthenticateState createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return const SignIn();
  }
}
