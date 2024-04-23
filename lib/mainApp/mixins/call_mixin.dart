// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../reusable/colors.dart';
import '../../reusable/style.dart';
import '../../reusable/navigator.dart';
import '../../constants/app_constants.dart';
import '../../reusable/sized_box_hw.dart';
import '../../constants/assets_constants.dart';
import '../controllers/chats_controller.dart';
import '../controllers/call_screen_controller.dart';
import '../../localDb/registration/signIn/sign_in_box.dart';
import '../callScreen/callComponents/calling_dialog_box.dart';

mixin CallMixin {
  static final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";
  ChatsController chatsController = Get.put(ChatsController());
  CallScreenController callScreenController = Get.put(CallScreenController());

  void startCalling({
    required Color color,
    required String title,
    required bool isCalling,
    required String connectingId,
    required String subTitle,
    required String documentId,
    required String profileImage,
    required BuildContext context,
  }) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd_HH:mm:ss').format(now);
    AppConstants.customAppBarCenterText.value = subTitle;
    String docId = '${documentId}_$formattedDate';
    if (chatsController.isAudioCalling.value == true) {
      await chatsController.cn.callHistory.doc(docId).set({
        'caller': currentUsersPhone,
        'callId': AppConstants.chatRoomModel!.chatRoomId,
        'callee': '${AppConstants.userNameToChat}',
        'timestamp': FieldValue.serverTimestamp(),
        'connectingId': connectingId,
        'startTime': null,
        'received': false,
        'callOff': false,
        'endTime': null,
        'callType': 'A',
      });
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CallingDialogbox(
                ringingMusic: 'audio/outgoing_music.mp3',
                showBackgroundImage: false,
                callingStatusText: 'Calling',
                profileImage: profileImage,
                isCalling: isCalling,
                subTitle: subTitle,
                color: color,
                title: title,
                docId: docId,
              )),
    );
  }

  void receiveCallingDialogBox(
    BuildContext context, {
    required Color color,
    required String title,
    required String docId,
    required bool isCalling,
    required String subTitle,
    required String profileImage,
  }) {
    pushSimple(CallingDialogbox(
      docId: docId,
      title: title,
      color: color,
      subTitle: subTitle,
      isCalling: isCalling,
      showBackgroundImage: true,
      profileImage: profileImage,
      callingStatusText: 'In-Coming',
      ringingMusic: 'audio/ringing_music.mp3',
    ));
  }

  Widget buildCallListTile({
    required int index,
    required Size size,
    required String docId,
    required String title,
    required String caller,
    required bool wasMissed,
    required bool isAudioCall,
    required Timestamp timestamp,
    required BuildContext context,
    required String profileImage,
  }) {
    String? callTime;
    DateTime now = DateTime.now();
    DateTime dateTime = timestamp.toDate();
    Duration difference = now.difference(dateTime);
    if (difference.inMinutes < 60) {
      callTime = '${difference.inMinutes} minutes ago';
    } else {
      String date = DateFormat('yyyy-MM-dd').format(dateTime);
      String time = DateFormat('HH:mm').format(dateTime);
      callTime = '$date $time';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: size.height * 0.11,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: white,
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              backgroundImage: NetworkImage(profileImage),
              radius: 25,
            ),
          ),
          sw20,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: tStyle20.copyWith(color: black)),
              sh10,
              Row(
                children: [
                  Icon(
                    (caller == currentUsersPhone) == true ? Icons.north_east : Icons.south_west_outlined,
                    size: 27,
                    color: wasMissed ? greenThree : red,
                  ),
                  sw10,
                  Text(
                    callTime,
                    style: tStyle14.copyWith(color: black),
                  ),
                ],
              )
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: difference.inMinutes < 1 && index == 0
                ? () {
                    receiveCallingDialogBox(context, color: green, title: title, docId: docId, isCalling: true, subTitle: 'call', profileImage: profileImage);
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(3),
              color: difference.inMinutes < 1 && index == 0 ? green : null,
              child: Icon(
                isAudioCall ? Icons.call : Icons.video_call,
                color: bgColor,
                size: 27,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoCallHistory() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AssetsConstants.noCallHistory),
          sh11,
          Text('Your call history is empty', style: tStyle14.copyWith(color: black)),
          sh10,
          Text('No Call History', style: tStyleBold24.copyWith(color: black)),
        ],
      );
  Widget buildLeadingPic(String image) => SizedBox(
        height: 50,
        width: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(300.0),
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: image,
            placeholder: (context, url) => const Center(
                child: Padding(
              padding: EdgeInsets.all(15.0),
              child: CircularProgressIndicator(strokeWidth: 1),
            )),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      );
  static String messageIdentifier() {
    String messageId = '';
    DateTime now = DateTime.now();
    List<String> parts = AppConstants.chatRoomModel!.chatRoomId.split('_');
    String formattedDate = DateFormat('yyyy-MM-dd_H:mm:ss').format(now);
    String rightSide = parts[1];
    String leftSide = parts[0];

    if (leftSide.contains(currentUsersPhone)) {
      messageId = 'R_$formattedDate';
    } else if (rightSide.contains(currentUsersPhone)) {
      messageId = 'S_$formattedDate';
    }
    return messageId;
  }

  Widget buildVideoControllButtons({
    required Color color,
    required IconData icon,
    required Function() onPressed,
  }) {
    return InkWell(
      splashColor: transparent,
      onTap: onPressed,
      child: Container(
        height: 50,
        width: 50,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, size: 15, color: white),
        ),
      ),
    );
  }

  //divider
  Padding customDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Divider(
        thickness: 1.5,
        color: greyLight,
      ),
    );
  }
}
