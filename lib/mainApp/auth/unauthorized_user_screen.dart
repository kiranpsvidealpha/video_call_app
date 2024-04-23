import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../reusable/buttons.dart';
import '../../reusable/colors.dart';
import '../../reusable/responsive.dart';
import '../../services/auth_services.dart';

class UnAuthorizedUser extends StatefulWidget {
  const UnAuthorizedUser({super.key, required this.action});
  final void Function() action;
  @override
  State<UnAuthorizedUser> createState() => _LoginState();
}

class _LoginState extends State<UnAuthorizedUser> {
  final AuthenticationService auth = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final user = Provider.of<User?>(context);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SizedBox(
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: Responsive.isDesktop(context) ? size.width * 0.4 : size.width * 0.8,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    "Logged in with Email\n${user!.email}\n\nThis account can not be used here please ask your admin for relevant permissions and then you can click on retry button below",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.1),
            SizedBox(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: Responsive.isDesktop(context) ? size.width * 0.4 : size.width * 0.8,
                    child: LogoedElevatedButton(
                      //function rechecking the permissions
                      onCLick: widget.action,
                      title: '  Retry checking permissions',
                      svg: 'retry',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: ListTile(
          tileColor: blue,
          onTap: () async {
            await auth.signOut(context);
          },
          title: const Text(
            'Login with another account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
