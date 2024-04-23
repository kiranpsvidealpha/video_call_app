// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:line_icons/line_icons.dart';
import 'package:video_call_app/mainApp/dashBoard/dashboard.dart';
import 'package:video_call_app/reusables/navigators.dart';

import '../../../reusables/colors.dart';
import '../../../reusables/snack_bar.dart';
import '../../../services/auth_services.dart';
import '../../bloc/login_with_email_bloc.dart';
import '../../reusables/assets_constants.dart';
import '../../reusables/loading_screen.dart';
import '../../reusables/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthenticationService auth = AuthenticationService();
  final GlobalKey<FormState> loginScreenFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController(text: null);
  TextEditingController passwordController = TextEditingController(text: null);
  ValueNotifier<bool> viewPassword = ValueNotifier<bool>(true);

  String appLogo = AssetsConstants.appLogo;
  @override
  void initState() {
    emailController.addListener(() {
      setState(() {});
    });
    passwordController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return BlocConsumer<EmailAuthBloc, EmailAuthState>(
      listener: (context, eas) {
        if (eas is EmailAuthFailure) {
          showSnackBar(context, eas.error, error: true);
        }
        if (eas is EmailAuthSuccess) {
          showSnackBar(
            context,
            "Logged in\nEmail:${eas.authResult!.user!.email}",
          );
        }
      },
      builder: (context, eas) {
        double width = size.width > 400 ? 400 : size.width;
        return eas is EmailAuthProgress
            ? const LoadingScreen(message: "Logging you in")
            : Scaffold(
                extendBody: true,
                extendBodyBehindAppBar: true,
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: size.width - 32,
                        child: Form(
                          key: loginScreenFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.topCenter,
                                child: SvgPicture.asset(
                                  width: 250,
                                  AssetsConstants.appLogo,
                                  colorFilter: const ColorFilter.mode(selectedClr, BlendMode.srcIn),
                                ),
                              ),
                              SizedBox(height: size.height * 0.08),
                              const Text(
                                "Sign in",
                                style: TextStyle(
                                  fontSize: 34,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),

                              const SizedBox(height: 5),
                              //Subheading
                              const Text(
                                "to access your dashboard",
                                style: TextStyle(fontSize: 12, letterSpacing: 1),
                              ),
                              const SizedBox(height: 20),
                              //email form field
                              SizedBox(
                                width: width,
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: "User ID *",
                                    suffixIcon: Icon(LineIcons.userShield),
                                  ),
                                  validator: (String? val) {
                                    return validateEmail(val!, true);
                                  },
                                ),
                              ),
                              const SizedBox(height: 25),
                              //Password form field
                              SizedBox(
                                width: width,
                                child: ValueListenableBuilder(
                                  valueListenable: viewPassword,
                                  builder: (BuildContext context, bool value, Widget? child) {
                                    return TextFormField(
                                      controller: passwordController,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                      obscureText: viewPassword.value,
                                      obscuringCharacter: "*",
                                      decoration: InputDecoration(
                                        labelText: "Password *",
                                        suffixIcon: IconButton(
                                          icon: Icon(viewPassword.value ? LineIcons.eye : LineIcons.eyeSlash),
                                          onPressed: () {
                                            viewPassword.value = !viewPassword.value;
                                          },
                                        ),
                                      ),
                                      validator: (String? val) {
                                        return validatePassword(val!);
                                      },
                                      onFieldSubmitted: (value) {
                                        LoginScreenAdmin(context);
                                      },
                                    );
                                  },
                                ),
                              ),

                              /// remember Me and Forgot password
                              SizedBox(
                                width: width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Remember me",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(fontSize: 12, letterSpacing: 1, color: grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: TextButton(
                                        onPressed: () async {
                                          hideKeyboard();
                                          setState(() {});
                                          if (validateEmail(emailController.text, true) != null) {
                                            showSnackBar(context, "Please enter a valid user id to proceed", error: true);
                                          } else {
                                            if (emailController.text.isEmpty) {
                                              showSnackBar(context, "Please enter your user id to proceed", error: true);
                                            } else {
                                              String result = await AuthenticationService().sendPasswordResetEmail(emailController.text);
                                              showSnackBar(context, result, error: result.contains("Error"));
                                            }
                                          }
                                        },
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "Forgot password ?",
                                              textAlign: TextAlign.right,
                                              style: TextStyle(fontSize: 12, letterSpacing: 1, color: grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: BottomAppBar(
                  color: passwordController.text.length >= 10 ? green : grey,
                  elevation: 0,
                  child: ListTile(
                    onTap: () {
                      LoginScreenAdmin(context);
                    },
                    title: const Text(
                      'Sign in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  Future<void> LoginScreenAdmin(BuildContext context) async {
    bool isValid = loginScreenFormKey.currentState!.validate();
    if (isValid) {
      context.read<EmailAuthBloc>().add(LoginUsingEmail(
            email: emailController.text,
            password: passwordController.text,
          ));
      pushSimple(context, const DashboardScreen());
    } else {
      showSnackBar(context, "Invalid email or password\nPlease retry", error: true);
    }
  }
}
