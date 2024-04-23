import 'package:get/get.dart';

class ValidatorsController extends GetxController {
  // Phone number validator
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field is required';
    }
    if (value.length != 10) {
      return 'Invalid phone number';
    }
    return null;
  }

  // OTP validator
  String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field is required';
    }
    if (value.length != 6) {
      return 'Invalid OTP';
    }
    return null;
  }

  // Email validator
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field is required';
    }
    const pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }
}
