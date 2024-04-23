import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dashBoard/dashboard.dart';
import '../splashScreen/splash_screen.dart';
import '../../bloc/detect_user_changes.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    context.read<DetectFirebaseUserChangesBloc>().add(StartFirebaseUserChangeListener());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetectFirebaseUserChangesBloc, DetectFirebaseUserChangesState>(
      builder: (context, dfc) {
        if (dfc is DetectFirebaseUserChangesSuccess) {
          debugPrint("email: ${dfc.user.email}");
          debugPrint("email: ${dfc.user.email}");
        }
        return dfc is DetectFirebaseUserChangesSuccess ? const DashboardScreen() : const SplashScreen();
      },
    );
  }
}
