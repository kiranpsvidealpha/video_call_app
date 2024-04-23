import 'package:flutter/material.dart';

import 'loader.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(child: LoaderContainerWithMessage(message: message)),
    );
  }
}
