import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../reusable/colors.dart';
import '../mixins/call_mixin.dart';
import 'callComponents/call_list_tile_widget.dart';

class FetchResult {
  final List<QueryDocumentSnapshot> docs;
  final bool isEmpty;

  FetchResult(this.docs, this.isEmpty);
}

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with CallMixin {
  // RxBool noCalls = true.obs;
  // final CallScreenController controller = Get.put(CallScreenController());
  // final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";

  // @override
  // void initState() {
  //   super.initState();
  //   fetchData();
  // }

  // Future<void> fetchData() async {
  //   try {
  //     final snapshot = await chatsController.cn.callHistory.orderBy('timestamp', descending: true).get();
  //     final callRoomSnapshot = snapshot;
  //     final filteredDocs = callRoomSnapshot.docs.where((document) {
  //       final phoneNumbers = document.id.split('_');
  //       return phoneNumbers[0] != currentUsersPhone && phoneNumbers[1] != currentUsersPhone;
  //     }).toList();

  //     if (filteredDocs.isEmpty) {
  //       noCalls.value = false;
  //     } else {
  //       final users = await Future.wait(filteredDocs.map((doc) async {
  //         final phoneNumbers = doc.id.split('_');
  //         final oppositePhoneNumber = phoneNumbers[0] == currentUsersPhone ? phoneNumbers[1] : phoneNumbers[0];
  //         return FirebaseHelper.getUserModelById(oppositePhoneNumber);
  //       }));

  //       final List<UserModel?> filteredUsers = users.whereType<UserModel>().toList();

  //       if (filteredUsers.isNotEmpty) {
  //         final UserModel targetUser = filteredUsers[0]!;
  //         controller.callInfoName.value = targetUser.name!;
  //         controller.callInfoProfilePic.value = targetUser.imageUrl!;
  //       }
  //     }
  //   } catch (error) {
  //     log('call_screen.dart', name: "Error fetching data: $error");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: white,
      body: CallListTileWidget(),
    );
  }
}
