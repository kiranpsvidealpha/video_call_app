import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../reusable/border.dart';
import '../../../reusable/buttons.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../constants/text_constants.dart';
import '../../../services/auth_services.dart';
import '../../../constants/assets_constants.dart';
import '../../../reusable/loading_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../../localDb/registration/signIn/sign_in_box.dart';
import '../../../localDb/registration/signIn/sign_in_model.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final appSignInkey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> logInFormKey = GlobalKey<FormState>();
  final AuthController authController = Get.put(AuthController());

  // using country picker in phone form field
  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IND",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "India",
    displayName: "India",
    displayNameNoCountryCode: "IN",
    e164Key: "",
  );
  // stored sign in form data in map
  Map<String, dynamic> appSignInData = <String, dynamic>{
    'phoneNumber': "",
    'countryCode': "",
  };
  var phone = "";

  saveSignInDataToHive() {
    final formattedPhoneNumber = getFormattedPhoneNumber();
    final signUpInfoBox = SignInInfoBox.signinInfoBox;
    final existingData = signUpInfoBox.fetchSignin ?? SignInModel();
    final dataToSave = existingData.copyWith(
      phoneNumber: formattedPhoneNumber,
    );
    signUpInfoBox.saveSignIn = dataToSave;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    authController.isButtonLoading.value = false;
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                sh20,
                const Text(
                  "Sign in",
                  style: TextStyle(fontSize: 26, color: black, fontWeight: FontWeight.bold),
                ),
                Image.asset(AssetsConstants.signInImg),
                Form(
                  key: logInFormKey,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onSaved: (newValue) {
                      appSignInData["phoneNumber"] = newValue;
                      saveSignInDataToHive();
                    },
                    controller: phoneController,
                    decoration: InputDecoration(
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: bgColor)),
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(top: 13, left: 10, right: 5),
                        child: InkWell(
                          onTap: () {
                            showCountryPicker(
                              favorite: <String>['IN', "AE"],
                              showPhoneCode: true,
                              context: context,
                              countryListTheme: const CountryListThemeData(bottomSheetHeight: 400),
                              onSelect: ((value) {
                                appSignInData["countryCode"] = value;
                                setState(() {
                                  selectedCountry = value;
                                });
                              }),
                            );
                          },
                          child: Text(
                            "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                            style: const TextStyle(fontSize: 16, color: black),
                          ),
                        ),
                      ),
                      focusedBorder: foucsBorder,
                      focusedErrorBorder: foucsBorderError,
                      errorBorder: errorBorder,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field is required';
                      }
                      return null;
                    },
                  ),
                ),
                Obx(() => authController.isButtonLoading.value
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: size.width * 0.7,
                        height: size.height * 0.08,
                        child: ColouredElevatedButton(
                          onCLick: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            const LoadingScreen(message: TextConstants.loading);
                            bool isValid = (logInFormKey.currentState != null && logInFormKey.currentState!.validate());
                            final phoneNumber = phoneController.text;
                            if (isValid) {
                              final formattedPhoneNumber = '+${selectedCountry.phoneCode}$phoneNumber';
                              authController.logInWithPhoneNumber(formattedPhoneNumber, context);
                              isLoggedIn = true;
                            }

                            if (logInFormKey.currentState!.validate()) {
                              logInFormKey.currentState!.save();
                            }
                          },
                          title: 'Login',
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getFormattedPhoneNumber() {
    String formattedPhoneNumber = '+${selectedCountry.phoneCode}${phoneController.text}';
    return formattedPhoneNumber;
  }
}
