// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../mainApp/model/user_model.dart';
import '../reusable/snackbar.dart';

class FirebaseHelper {
  static final Map<String, UserModel> _cachedUserModels = {};

  static Future<UserModel?> getUserModelById(String uid) async {
    log('firebase helper.dart', name: "firebase helper");
    // Check if the UserModel has been cached
    if (_cachedUserModels.containsKey(uid)) {
      return _cachedUserModels[uid];
    }

    UserModel? usermodel;
    // Fetch UserModel from Firestore
    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (docSnap.data() != null) {
      usermodel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);

      // Cache the fetched UserModel
      _cachedUserModels[uid] = usermodel;
    }

    return usermodel;
  }

  static Future<bool> checkUserBlock(BuildContext context) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('chatRooms').doc(AppConstants.chatRoomModel!.chatRoomId).get();

    Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      Map<String, dynamic> participants = data['participants'];

      bool isAnyParticipantFalse = participants.values.any((value) => value == false);

      if (isAnyParticipantFalse) {
        showSnackBar(context, 'Contact Blocked', error: true);
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }
}
