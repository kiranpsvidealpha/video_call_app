//Email id validator
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

String? validateEmail(String val, bool isId) {
  String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = RegExp(pattern);
  //checking for empty value
  if (val.isEmpty) {
    return "Required field";
  } else {
    //matching the regular expression
    if (!regExp.hasMatch(val)) {
      return "Enter valid ${isId ? 'user id' : 'email'}";
    } else {
      return null;
    }
  }
}

//Password validator
String? validatePassword(String val) {
  RegExp upperCaseRegExp = RegExp(r'[A-Z]');
  RegExp lowerCaseRegExp = RegExp(r'[a-z]');
  RegExp digitRegExp = RegExp(r'\d');
  RegExp specialCharRegExp = RegExp(r'[!@#\$&*~]');

  bool hasUpperCase = upperCaseRegExp.hasMatch(val);
  bool hasLowerCase = lowerCaseRegExp.hasMatch(val);
  bool hasDigit = digitRegExp.hasMatch(val);
  bool hasSpecialChar = specialCharRegExp.hasMatch(val);
  bool isLengthValid = val.length >= 10;

  if (val.isEmpty) {
    return "Required field";
  } else if (!hasUpperCase) {
    return 'Password must contain at least 1 uppercase letter';
  } else if (!hasLowerCase) {
    return 'Password must contain at least 1 lowercase letter';
  } else if (!hasDigit) {
    return 'Password must contain at least 1 number';
  } else if (!hasSpecialChar) {
    return 'Password must contain at least 1 special character';
  } else if (!isLengthValid) {
    return 'Password must be at least 10 characters long';
  } else {
    return null;
  }
}
//Password validator
String? validateAndMatchPasswords(String val1,String val2) {
  String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{10,}$';
  RegExp regExp = RegExp(pattern);
  //checking for empty value
  if (val1.isEmpty) {
    return "Required field";
  } else {
    //matching the regular expression
    if (val1.length < 10) {
      return "Required password length is > 10";
    } else {
      if (!regExp.hasMatch(val1)) { 
        return "Password must match minimum standard";
      } else {
        if(val1 != val2){
          return "Confirm password not matching with password";
        }else{return null;}
      }
    }
  }
}


RegExp decimalNumberRegex =  RegExp(r'^(?=\D*(?:\d\D*){1,12}$)\d+(?:\.\d{1,4})?$');

// use for checking phone number validation country wise

bool isValidPhoneNumber(String phoneNumber) {
  final parsedNumber = PhoneNumber.parse(phoneNumber);
  return parsedNumber.isValid();
}