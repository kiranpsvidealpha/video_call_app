import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../localDb/chat/chat_list_box_model.dart';
import '../../localDb/registration/signIn/sign_in_box.dart';
import '../controllers/chats_controller.dart';
import '../../reusable/firebase_streams.dart';
import '../../services/firebase_helper.dart';
import '../../reusable/sized_box_hw.dart';
import '../../constants/app_constants.dart';
import 'chatComponents/chat_list_tile.dart';
import '../../constants/time_utility.dart';
import '../model/chat_room_model.dart';
import '../mixins/chat_mixin.dart';
import '../model/chat_model.dart';
import '../model/user_model.dart';
import 'chatting_screen.dart';
import 'chat_widgets.dart';
import '../../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with ChatMixin {
  ChatsController chatsController = Get.put(ChatsController());
  final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";
  final TextEditingController searchController = TextEditingController();
  List<String> participantsKeys = [];
  Future<void> handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => chatListTileStream());
  }

  ChatListBoxModel dataToSave = ChatListBoxModel();
  @override
  Widget build(BuildContext context) {
    chatsController.isSearchingChats.value = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sh5,
        Expanded(
          child: Obx(
            () => chatsController.isSearchingChats.value == true
                ? StreamBuilder(
                    stream: controller.determineQueryStream(chatsController.searchChat.text),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                        if (dataSnapshot.docs.isNotEmpty) {
                          return RefreshIndicator(
                            onRefresh: handleRefresh,
                            child: ListView.builder(
                                itemCount: dataSnapshot.docs.length,
                                itemBuilder: (context, index) {
                                  var userDocument = dataSnapshot.docs[index];

                                  ChatsModel chatsModel = ChatsModel(
                                    userName: userDocument['name'],
                                    uid: userDocument['phoneNumber'],
                                    isOnline: userDocument['isOnline'],
                                    lastOnline: Timestamp.now(),
                                    lastMessage: userDocument['lastMessage'],
                                    profilePicture: userDocument['imageProfile'],
                                    lastSeen: userDocument['chatListTrailingTime'],
                                  );
                                  return GestureDetector(
                                    onSecondaryTapDown: (TapDownDetails details) => chatListTileMenuBox(context, details.globalPosition, chatsModel),
                                    onTap: () async {
                                      controller.isSearching.value = false;
                                      controller.isSearchTileTapped.value = index;
                                      await chatsController.getChatRoomModel(chatsModel);
                                      if (chatsController.chatRoom != null) {
                                        setState(() {
                                          Get.to(() => ChattingScreen(targetNumber: userDocument['phoneNumber']), transition: Transition.rightToLeft);
                                          AppConstants.showChatScreen.value = true;
                                          AppConstants.emailToChat.value = userDocument['email'];
                                          AppConstants.numberToChat.value = userDocument['phoneNumber'];
                                          AppConstants.userNameToChat.value = userDocument['name'];

                                          if (userDocument['isOnline'] == true) {
                                            AppConstants.lastOnline.value = 'Online';
                                          } else {
                                            DateTime dateTime = TimeUtility.parseTimestamp(userDocument['chatListTrailingTime']);
                                            AppConstants.lastOnline.value = DateFormat('HH:mm').format(dateTime);
                                          }
                                          AppConstants.numberToChat.value = userDocument['phoneNumber'];
                                          AppConstants.profileImageToChat.value = userDocument['imageProfile'];
                                        });
                                      } else {
                                        log('chat_page.dart', name: "null is chatroom");
                                      }
                                    },
                                    child: chatListTile(
                                      index: index,
                                      title: userDocument['name'],
                                      isOnline: userDocument['isOnline'],
                                      lastMssg: userDocument['lastMessage'],
                                      profileImage: userDocument['imageProfile'],
                                      trailingTime: userDocument['chatListTrailingTime'],
                                    ),
                                  );
                                }),
                          );
                        } else {
                          return RefreshIndicator(onRefresh: handleRefresh, child: Center(child: ListView(children: [buildNoResult()])));
                        }
                      } else {
                        return buildNoResult();
                      }
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: chatListTileStream(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (!snapshot.hasData) {
                          return const Text("Network Issue");
                        }
                        QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                        chatsController.filteredDocuments = chatRoomSnapshot.docs.where((document) => document.id.contains(currentUsersPhone)).toList();
                        return RefreshIndicator(
                          onRefresh: handleRefresh,
                          child: ListView.builder(
                            itemCount: chatsController.filteredDocuments.length,
                            itemBuilder: (context, index) {
                              ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(chatsController.filteredDocuments[index].data() as Map<String, dynamic>);
                              Map<String, dynamic> participants = chatRoomModel.participants!;
                              participantsKeys = participants.keys.toList();
                              participantsKeys.remove(currentUsersPhone);
                              return FutureBuilder(
                                future: FirebaseHelper.getUserModelById(participantsKeys[0]),
                                builder: (context, userData) {
                                  if (userData.data != null) {
                                    chatsController.targetUser = userData.data as UserModel;
                                    ChatsModel chatsModel = ChatsModel(
                                      uid: chatsController.targetUser!.phone,
                                      lastOnline: Timestamp.now(),
                                      isOnline: chatsController.targetUser!.isOnline!,
                                      userName: chatsController.targetUser!.name.toString(),
                                      lastSeen: chatsController.targetUser!.chatListTrailingTime!,
                                      lastMessage: chatsController.targetUser!.userLastMessage,
                                      profilePicture: chatsController.targetUser!.imageUrl.toString(),
                                    );
                                    dataToSave = ChatListBoxModel(
                                      chatRoomModel: chatRoomModel,
                                      isMessageRead: (index == 0 || index == 3 || index == 5) ? true : false,
                                      time: chatsController.targetUser!.chatListTrailingTime!,
                                      targetUser: chatsController.targetUser!,
                                      chatsModel: chatsModel,
                                      lastMssg: chatsController.targetUser!.userLastMessage!,
                                    );
                                    chatListBox.put('chatbox', dataToSave);
                                    return ChatListTile(
                                      isMessageRead: dataToSave.isMessageRead!,
                                      time: dataToSave.time!,
                                      targetUser: dataToSave.targetUser!,
                                      chatRoomModel: chatRoomModel,
                                      chatsModel: dataToSave.chatsModel!,
                                      lastMssg: dataToSave.lastMssg!,
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              );
                            },
                          ),
                        );
                      } else {
                        //To show offline chats
                        return buildNoResult();
                      }
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
