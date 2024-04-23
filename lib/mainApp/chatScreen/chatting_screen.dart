import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../localDb/registration/signIn/sign_in_box.dart';
import '../controllers/sent_message_controller.dart';
import 'chatComponents/chat_detail_page_appbar.dart';
import '../../reusable/firebase_streams.dart';
import '../controllers/chats_controller.dart';
import '../../services/firebase_helper.dart';
import '../../constants/assets_constants.dart';
import '../model/chat_message_model.dart';
import '../../constants/app_constants.dart';
import '../../constants/time_utility.dart';
import '../../reusable/style.dart';
import '../mixins/chat_mixin.dart';
import '../../reusable/loader.dart';
import '../mixins/call_mixin.dart';
import '../../reusable/colors.dart';
import 'chat_widgets.dart';

enum MessageType {
  sender,
  receiver,
}

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({super.key, required this.targetNumber});
  final String targetNumber;
  @override
  ChattingScreenState createState() => ChattingScreenState();
}

class ChattingScreenState extends State<ChattingScreen> with ChatMixin {
  String typedMessage = "";
  FocusNode focusNode = FocusNode();
  TextEditingController messageController = TextEditingController();
  SentMessageController sentMessageController = Get.put(SentMessageController());
  ChatsController chatsController = Get.put(ChatsController());
  final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";
  List<MessagesModel> chatMessages = [];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: ChatDetailPageAppBar(targetNumber: widget.targetNumber),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            Get.back();
          }
        },
        child: Column(
          children: <Widget>[
            Obx(() => chatsController.sendingDataLoader.value == true ? loadingBar() : const SizedBox.shrink()),
            const SizedBox(height: 5),
            Expanded(
              child: StreamBuilder(
                stream: chatViewScreenStream(AppConstants.chatRoomModel!.chatRoomId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: LoaderContainerWithMessage(message: "Loading.."));
                  } else {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    return Stack(
                      alignment: Alignment.bottomCenter,
                      fit: StackFit.expand,
                      children: [
                        Image.asset(AssetsConstants.chatViewBgTwo, fit: BoxFit.cover),
                        buildChatUI(dataSnapshot: dataSnapshot, size: size),
                      ],
                    );
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5),
              width: double.infinity,
              color: black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor: transparent,
                        context: context,
                        builder: (builder) => bottomSheet(context, false),
                      );
                    },
                    child: Transform.rotate(
                      angle: -45 * (3.141592653589793238462643383279502884 / 180),
                      child: const Icon(Icons.attachment_outlined, color: white, size: 30),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        minLines: 1,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: "Type message...",
                          hintStyle: TextStyle(color: grey.shade500),
                          border: InputBorder.none,
                        ),
                        onChanged: (text) {
                          typedMessage = text;
                        },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (typedMessage.isNotEmpty) {
                        onSubmitMessage(typedMessage);
                      } else {
                        showModalBottomSheet(
                          backgroundColor: transparent,
                          context: context,
                          builder: (builder) => bottomSheet(context, true),
                        );
                      }
                    },
                    child: const Icon(Icons.send, color: white, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChatUI({required QuerySnapshot dataSnapshot, required Size size}) => ListView.builder(
        reverse: true,
        itemCount: dataSnapshot.docs.length,
        itemBuilder: ((context, index) {
          String date = '';
          MessagesModel currentMessage = MessagesModel.fromMap(dataSnapshot.docs[index].data() as Map<String, dynamic>);
          DateTime dateTime = TimeUtility.parseTimestamp(currentMessage.timeMessageSend!);
          date = DateFormat('yyyy-MM-dd').format(dateTime);
          bool isSentByCurrentUser = false;
          isSentByCurrentUser = currentMessage.isSentByMe == currentUsersPhone;
          CrossAxisAlignment crossAxisAlignment = (isSentByCurrentUser) ? CrossAxisAlignment.end : CrossAxisAlignment.start;
          // Widget selectableText(String text) {
          //   return SelectableText(text, maxLines: null, style: tStyle14.copyWith(color: isSentByCurrentUser ? black : white));
          // }

          DateTime today = DateTime.now();
          bool isToday = DateTime(dateTime.year, dateTime.month, dateTime.day) == DateTime(today.year, today.month, today.day);
          bool showDateSeparator = index + 1 == dataSnapshot.docs.length || date != DateFormat('yyyy-MM-dd').format(dataSnapshot.docs[index + 1]['timeMessageSend'].toDate());

          return Column(
            children: [
              if (showDateSeparator)
                Container(
                  decoration: BoxDecoration(color: bgLightColor, borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    isToday ? 'Today' : date,
                    style: tStyleBold12.copyWith(color: white),
                  ),
                ),
              Row(
                mainAxisAlignment: (isSentByCurrentUser) ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: isSentByCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: isSentByCurrentUser ? selectedTileClr : bgColor.withOpacity(.7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: const Radius.circular(8),
                                  bottomRight: const Radius.circular(8),
                                  topLeft: isSentByCurrentUser ? const Radius.circular(9) : const Radius.circular(0),
                                  topRight: isSentByCurrentUser ? const Radius.circular(0) : const Radius.circular(8),
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: crossAxisAlignment,
                              children: [
                                selectableText(currentMessage.text.toString(), isSentByCurrentUser, size),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm').format(dateTime),
                                      style: tStyle10.copyWith(color: isSentByCurrentUser ? grey : white),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Icon(size: 10, Icons.check, color: isSentByCurrentUser ? black : white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      );

  void onSubmitMessage(String text) async {
    try {
      var isNotBlock = await FirebaseHelper.checkUserBlock(context);
      if (isNotBlock == true) {
        MessagesModel onSubmitMessage = MessagesModel(
          text: text,
          isSentByMe: currentUsersPhone,
          timeMessageSend: Timestamp.now(),
          messageId: CallMixin.messageIdentifier(),
        );
        messageController.clear();
        // FocusScope.of(context).requestFocus(focusNode);
        controller.updateStream(chatRoomId: AppConstants.chatRoomModel!.chatRoomId);

        controller.cn.chatRooms.doc(AppConstants.chatRoomModel!.chatRoomId).collection('messages').doc(onSubmitMessage.messageId).set(onSubmitMessage.toMap());
        if (text != '') {
          controller.cn.chatRooms
              .doc(AppConstants.chatRoomModel!.chatRoomId)
              .update({'lastMessage': onSubmitMessage.text, 'chatListTrailingTime': onSubmitMessage.timeMessageSend});
        }
        controller.audioLink = '';
        controller.isTapped.value = 0;
        AppConstants.latitude = '0';
        AppConstants.longitude = '0';
      }
    } catch (e) {
      log('chat_detail_page.dart', name: "Exception error", error: e);
    }
  }
}
