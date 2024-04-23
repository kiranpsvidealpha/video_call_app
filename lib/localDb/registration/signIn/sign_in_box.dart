import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../constants/app_constants.dart';
import 'sign_in_model.dart';

class SignInInfoBox with AppConstants {
  static const String hiveBoxKey = AppConstants.hiveBoxKey;
  static const String signinBoxKey = AppConstants.signInKey;
  late Box _signinBox;

  SignInInfoBox._() {
    _signinBox = Hive.box(hiveBoxKey);
  }

  static final SignInInfoBox _singleton = SignInInfoBox._();

  factory SignInInfoBox() => _singleton;

  static SignInInfoBox get signinInfoBox => _singleton;

  // Save sign in information to the database
  set saveSignIn(SignInModel value) {
    _signinBox.put(signinBoxKey, value).catchError(
      (error, stack) {
        log("Error", name: "Hive sign in info saving error >>", error: error, stackTrace: stack);
      },
    );
  }

  void clearSignIn() {
    try {
      _signinBox.delete(signinBoxKey);
    } catch (e) {
      log("Error", name: "Hive sign in info clearing error >>", error: e);
    }
  }

  // Retrieve sign in information from the database
  SignInModel? get fetchSignin {
    late SignInModel? value;
    try {
      value = _signinBox.get(signinBoxKey);
      return value;
    } catch (e) {
      log("Error", name: "Hive sign in info fetching error >>", error: e);
      return value;
    }
  }
}
