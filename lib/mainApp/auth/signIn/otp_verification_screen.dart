import 'dart:developer';

import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:get/get.dart';

import '../../../reusable/colors.dart';
import '../../../reusable/buttons.dart';
import '../../../services/validators.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../constants/assets_constants.dart';
import '../../controllers/auth_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String number;

  const OtpVerificationScreen({super.key, required this.verificationId, required this.number});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final AuthController authController = Get.find<AuthController>();
  final ValidatorsController validatorsController = Get.put(ValidatorsController());
  OtpTimerButtonController controller = OtpTimerButtonController();

  String? otpCode;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: bgColor,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: bgColor),
        borderRadius: BorderRadius.circular(8),
      ),
    );
    // pin box decoration
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: bgColor),
      borderRadius: BorderRadius.circular(8),
    );
    // pin box decoration
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: white,
      ),
    );
    return SafeArea(
      child: Scaffold(
        backgroundColor: white,
        body: Container(
          margin: const EdgeInsets.all(15),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Mobile No Verification",
                  style: TextStyle(fontSize: 22, color: black, fontWeight: FontWeight.bold),
                ),
                sh20,
                Text(
                  "We have sent an OTP on your mobile\nNo : ${widget.number} ",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                sh60,
                Image.asset(
                  AssetsConstants.otpBg,
                  height: size.height / 3.8,
                ),
                sh60,
                // pinput widget
                Pinput(
                  length: 6,
                  autofocus: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  showCursor: true,
                  onCompleted: (value) async {
                    setState(() {
                      otpCode = value;
                    });
                    String verificationId = widget.verificationId;
                    String otp = otpCode ?? '';
                    try {
                      await authController.signUpOtpVerify(verificationId, otp, widget.number, context);
                    } catch (e) {
                      log('Error during OTP verification: $e');
                    }
                  },
                  validator: (String? val) {
                    return validatorsController.validateOTP(val);
                  },
                ),
                sh20,
                Align(
                    alignment: Alignment.centerRight,
                    child: OtpTimerButton(
                      controller: controller,
                      onPressed: () {
                        authController.logInWithPhoneNumber(widget.number, context);
                        setState(() {
                          authController.resendCodeDuration = 30;
                        });
                      },
                      buttonType: ButtonType.text_button,
                      text: const Text(
                        'Resend OTP',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: bgColor),
                      ),
                      duration: authController.resendCodeDuration,
                    )),
                SizedBox(
                  width: size.width * 0.7,
                  height: size.height * 0.08,
                  child: ColouredElevatedButton(
                    onCLick: () async {
                      String verificationId = widget.verificationId;
                      String otp = otpCode ?? '';
                      try {
                        await authController.signUpOtpVerify(verificationId, otp, widget.number, context);
                      } catch (e) {
                        log('Error during OTP verification: $e');
                      }
                    },
                    title: 'Verify OTP',
                  ),
                ),
                SizedBox(height: size.height * 0.035),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(fontWeight: FontWeight.bold, color: bgColor, fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.035),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
