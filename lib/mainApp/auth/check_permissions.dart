import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../appPermissions/permissions_screen.dart';
import 'signIn/sign_in_screen.dart';
import '../../reusable/loader.dart';
import '../network/no_internet.dart';
import 'unauthorized_user_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    context.read<NetworkBloc>().add(NetworkObserve());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NetworkBloc, NetworkState>(
      listener: (context, state) {
        log(state.toString().split('\'')[1], name: "[Network State ] >>");
      },
      builder: (context, state) {
        if (state is NetworkSuccess) {
          final user = Provider.of<User?>(context);
          // return either the main or Authenticate screen
          if (user == null) {
            return const AppPermissions();
          } else {
            return const ClaimsWrapper();
          }
        } else {
          return NoInternetView(
            msg: state is NetworkInitial ? "Checking Connection !" : "No Internet",
            showInfo: state is NetworkFailure,
          );
        }
      },
    );
  }
}

class ClaimsWrapper extends StatefulWidget {
  const ClaimsWrapper({super.key});

  @override
  State<ClaimsWrapper> createState() => _ClaimsWrapperState();
}

class _ClaimsWrapperState extends State<ClaimsWrapper> {
  bool allowed = false;
  bool admin = false;
  bool checked = false;

  permissionChecks(User user) async {
    IdTokenResult res = await user.getIdTokenResult(true);
    if (res.claims == null) {
      setState(() {
        checked = true;
      });
    } else if (res.claims != null) {
      setState(() {
        checked = true;
        allowed = res.claims!['enabled'] ?? false;
        admin = res.claims!['admin'] ?? false;
      });
    }
  }

  permissionRecheck(User user) async {
    setState(() {
      checked = false;
      allowed = false;
      admin = false;
    });
    permissionChecks(user);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (!checked) {
      permissionChecks(user!);
    }

    return checked && allowed && admin
        ? const SignIn()
        : checked
            ? UnAuthorizedUser(action: () {
                permissionRecheck(user!);
              })
            : const Scaffold(
                body: SafeArea(
                  child: LoaderContainerWithMessage(message: "Checking Permissions"),
                ),
              );
  }
}
