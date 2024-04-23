// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chats_controller.dart';
import '../../reusable/snackbar.dart';
import '../../reusable/navigator.dart';
import '../../constants/app_constants.dart';
import '../../constants/text_constants.dart';
import '../model/personal_info_model.dart';
import '../../reusable/collection_names.dart';
import '../dashboard_screen.dart';
import '../auth/signIn/otp_verification_screen.dart';

class AuthController extends GetxController {
  int resendCodeDuration = 30;
  BuildContext? context;
  late String email = '';
  late String username = '';
  late String phoneNumber = '';
  RxBool isButtonLoading = false.obs;
  CollectionNames cn = CollectionNames();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool get loggedIn {
    User? user = auth.currentUser;
    return user != null;
  }

  void setContext(BuildContext ctx) {
    context = ctx;
  }

  Future<void> logInWithPhoneNumber(String phoneNumber, BuildContext context) async {
    try {
      this.phoneNumber = phoneNumber;
      checkUserExist(
        number: phoneNumber,
        isSignUp: false,
        context: context,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  // Verify OTP
  Future<void> signUpOtpVerify(String verificationId, String otpCode, String number, BuildContext context) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      await auth.signInWithCredential(credential);
      await creatingUser(
        number,
        email,
        username,
      );
      PersonalInfoModel personalInfoModel = PersonalInfoModel(
        myName: username,
        myEmailId: email,
        myMobileNumber: number,
      );
      await cn.users.doc(number).update({'isOnline': true});
      AppConstants.personalInfoModel = personalInfoModel;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      showSnackBar(context, 'Error signing in with credentials', error: true);
    }
  }

  Future<void> checkUserExist({
    String? email,
    String? name,
    required String number,
    required bool isSignUp,
    required BuildContext context,
  }) async {
    try {
      DocumentSnapshot userData = await cn.users.doc(number).get();
      isButtonLoading.value = true;
      if (userData.exists) {
        if (isSignUp) {
          showSnackBar(context, 'User with the same phone number already exists. Please sign in.', error: true);
        } else {
          log('userData.exists');
        }
        PersonalInfoModel personalInfoModel = PersonalInfoModel(
          myName: userData['name'],
          myEmailId: userData['email'],
          myMobileNumber: number,
        );
        ChatsController.personalInfoModel = personalInfoModel;
        await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {},
          verificationFailed: (FirebaseAuthException e) {
            log(e.toString());
          },
          codeSent: (String verificationId, int? resendToken) async {
            if (isSignUp == false) {
              isButtonLoading.value = false;
              pushSimple(OtpVerificationScreen(verificationId: verificationId, number: number));
            } else
            //  pushSimple(context, OtpVerificationScreen(verificationId: verificationId, number: number))
            {
              null;
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            log('codeAutoRetrievalTimeout: ${verificationId.camelCase}');
          },
        );
        log('after-- verify number');
      } else {
        log('No there----!!');
        showSnackBar(context, 'No user with this phone number found.', error: true);
        if (isSignUp == true) {
          await auth.verifyPhoneNumber(
            phoneNumber: number,
            verificationCompleted: (credential) async {},
            verificationFailed: (authException) => verificationFailed(authException, username),
            codeSent: (String verificationId, int? resendToken) async {
              if (!userData.exists) {
                pushSimple(OtpVerificationScreen(verificationId: verificationId, number: number));
                isButtonLoading.value = false;
              }
            },
            codeAutoRetrievalTimeout: (String verificationId) {},
          );
        } else {
          isButtonLoading.value = false;
        }
      }
    } on FirebaseAuthException catch (ex) {
      log(ex.message.toString());
    }
  }

  String? getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      return uid;
    }
    return null;
  }

  Future<void> creatingUser(
    String phoneNumber,
    String email,
    String username,
  ) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: phoneNumber,
      );
    } on FirebaseAuthException catch (e) {
      log('Error creating user: $e');
    }
    if (credential != null) {
      String? uid = getCurrentUserUid();
      await cn.users.doc(phoneNumber).set({
        'uid': uid,
        'email': email,
        'profession': '',
        'name': username,
        'isOnline': true,
        'phoneNumber': phoneNumber,
        'status': TextConstants.active,
        'chatListTrailingTime': Timestamp.now(),
        'lastMessage': 'say hi to your new friend',
        'imageProfile': AppConstants.firstProfilePic,
        'profileBanner': AppConstants.firstProfileBannerPic
        // 'imageProfile': 'https://i.ibb.co/BNCZgB6/profile.png',
      }).then((value) {});
    }
  }

  void verificationFailed(FirebaseAuthException authException, String username) {
    log('Phone verification failed for $username: $authException');
  }
}
