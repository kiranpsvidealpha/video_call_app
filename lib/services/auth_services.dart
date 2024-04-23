import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool isLoggedIn = false;

class AuthenticationService {
  FirebaseAuth auth = FirebaseAuth.instance;
  //firebase auth change stream
  Stream<User?> get authStateChanged {
    return auth.authStateChanges();
  }

  User? currentUser() {
    return auth.currentUser;
  }

  Future<void> checkUserState() async {
    await for (User? user in auth.authStateChanges()) {
      if (user != null) {
        isLoggedIn = true;
      } else {
        isLoggedIn = false;
      }
    }
  }

  //Firebase email password login

  Future<UserCredential?> signInUsingEmail(String email, String password) async {
    try {
      UserCredential? userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint("code: ${e.code.toString()}");
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      } else if (e.code == 'network-request-failed') {
        throw 'A network error occurred. Please check your internet connection and try again.';
      } else {
        throw 'Unable to reach our backend';
      }
    } catch (e) {
      // Handle generic error
      throw 'An unexpected error occurred: $e';
    }
  }

  //reset user password

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      return await auth.sendPasswordResetEmail(email: email).then((value) {
        return "Please check your email $email for further instructions";
      });
    } on FirebaseAuthException catch (e) {
      log("$e", name: "Firebase auth error");
      return e.code == "user-not-found" ? "Error : User doesn't exist" : "Error : Unable to reach backend";
    }
  }

  //logout current user

  Future signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      isLoggedIn = false;
      // Get.offAll(const SignIn(),transition: Transition.rightToLeft);
    } catch (e) {
      if (kDebugMode) log("Error during sign-out: $e");
    }
  }
}
