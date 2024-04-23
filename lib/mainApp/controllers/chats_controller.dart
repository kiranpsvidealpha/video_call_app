// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:developer';

import 'package:agora_token_service/agora_token_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../localDb/registration/signIn/sign_in_box.dart';
import '../../reusable/collection_names.dart';
import '../model/current_chat_details_model.dart';
import '../model/personal_info_model.dart';
import '../../constants/text_constants.dart';
import '../../constants/app_constants.dart';
import '../../constants/time_utility.dart';
import '../model/chat_room_model.dart';
import 'agora_video_controller.dart';
import '../model/chat_model.dart';
import '../model/user_model.dart';

class ChatsController extends GetxController {
  RxBool showVideoCallScreen = false.obs;
  RxBool expandableSearchBar = false.obs;
  int toggle = 0;

  String audioLink = '';
  UserModel? targetUser;
  ChatRoomModel? chatRoom;
  RxInt isTapped = (-1).obs;
  bool isFileSelected = false;
  RxBool isSearching = false.obs;
  RxBool isSearchingChats = false.obs;
  List searchingChatsList = []; //for search
  RxBool changeState = false.obs;
  RxBool sendingData = false.obs;
  RxInt? currentTappedChat = 0.obs;
  RxBool isVideoCall = false.obs;
  RxInt isSearchTileTapped = 0.obs;
  RxBool isAudioCalling = false.obs;
  CollectionNames cn = CollectionNames();
  RxBool isBlockContact = true.obs;
  RxBool isOnGoingCall = false.obs;
  RxBool isRingingCall = false.obs;
  RxBool showMediaFragment = false.obs;
  final searchFocusNode = FocusNode();
  RxBool sendingDataLoader = false.obs; //show when image send to chat
  RxBool isContactInfoVisible = false.obs;
  CurrentChatDetailsModel? currentChatDetails;
  RxBool isAttachFileVisible = false.obs;
  static PersonalInfoModel? personalInfoModel;
  final streamController = StreamController<QuerySnapshot>();
  TextEditingController searchChat = TextEditingController();
  TextEditingController searchCallLogs = TextEditingController();
  TextEditingController searchContact = TextEditingController();
  Stream<QuerySnapshot> get myStream => streamController.stream;
  List<QueryDocumentSnapshot<Object?>> filteredDocuments = [];
  final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";

  @override
  void onInit() {
    super.onInit();
    streamController.onResume;
  }

  @override
  void onClose() {
    streamController.close();

    super.onClose();
  }

  /////////////////////////////////////////////////////////////////////////////////
  Future<ChatRoomModel?> getChatRoomModel(ChatsModel targetUser) async {
    QuerySnapshot snapshot = await cn.chatRooms
        .where(
          'participants.$currentUsersPhone',
          isEqualTo: true,
        )
        .where(
          'participants.${targetUser.uid}',
          isEqualTo: true,
        )
        .get();
    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
      log('chatroom already created');
    } else {
      ChatRoomModel chatRoomModel = ChatRoomModel(
        name: targetUser.userName,
        phoneNumber: targetUser.uid!,
        isOnline: targetUser.isOnline,
        chatListTrailingTime: targetUser.lastOnline,
        lastMessage: targetUser.lastMessage,
        imageProfile: targetUser.profilePicture,
        chatRoomId: '${targetUser.uid!}_$currentUsersPhone',
        participants: {currentUsersPhone: true, targetUser.uid.toString(): true},
      );
      await cn.chatRooms.doc(chatRoomModel.chatRoomId).set(chatRoomModel.toMap());
      chatRoom = chatRoomModel;
    }
    AppConstants.chatModel = targetUser;
    AppConstants.chatRoomModel = chatRoom;
    updateStream(chatRoomId: AppConstants.chatRoomModel!.chatRoomId);
    return chatRoom;
  }

  /////////////////////////////////////////////////////////////////////////////////
  Stream<QuerySnapshot> determineQueryStream(String searchText) {
    String sanitizedQuery = searchText.toLowerCase();
    String findingElement;
    if (sanitizedQuery.contains('@')) {
      findingElement = 'email';
    } else {
      findingElement = 'name';
    }
    return cn.users.where(findingElement, isGreaterThanOrEqualTo: sanitizedQuery).where(findingElement, isLessThanOrEqualTo: '$sanitizedQuery\uf8ff').snapshots();
  }

  /////////////////////////////////////////////////////////////////////////////////
  void filterSearchResults(String query) async {
    filteredDocuments.clear();

    if (query.isEmpty) {
      return;
    }

    String lowercaseQuery = query.toLowerCase();
    QuerySnapshot querySnapshot = await cn.users.where('name', isGreaterThanOrEqualTo: lowercaseQuery).where('name', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff').get();

    for (QueryDocumentSnapshot<Object?> doc in querySnapshot.docs) {
      String docName = (doc.data() as Map<String, dynamic>)['name'];

      if (docName.toLowerCase() == lowercaseQuery) {
        filteredDocuments.add(doc);
      } else if (docName.toLowerCase().startsWith(lowercaseQuery)) {
        filteredDocuments.add(doc);
      }
    }

    // setState(() {});
  }

  /////////////////////////////////////////////////////////////////////////////////
  Future<void> clearChat(ChatsModel targetUser) async {
    try {
      String documentId1 = '${targetUser.uid}_$currentUsersPhone';
      String documentId2 = '${currentUsersPhone}_${targetUser.uid}';

      CollectionReference chatRoomsCollection = cn.chatRooms;

      QuerySnapshot snapshot = await chatRoomsCollection.where('participants.$currentUsersPhone', isEqualTo: true).where('participants.${targetUser.uid}', isEqualTo: true).get();
      if (snapshot.docs.isNotEmpty) {
        WriteBatch batch = FirebaseFirestore.instance.batch();
        QuerySnapshot messagesSnapshot1 = await chatRoomsCollection.doc(documentId1).collection('messages').get();
        QuerySnapshot messagesSnapshot2 = await chatRoomsCollection.doc(documentId2).collection('messages').get();
        QuerySnapshot imageSnapshot1 = await chatRoomsCollection.doc(documentId1).collection('images').get();
        QuerySnapshot imageSnapshot2 = await chatRoomsCollection.doc(documentId2).collection('images').get();

        List<QueryDocumentSnapshot> messagesDocuments1 = messagesSnapshot1.docs;
        List<QueryDocumentSnapshot> messagesDocuments2 = messagesSnapshot2.docs;
        List<QueryDocumentSnapshot> imagesDocuments1 = imageSnapshot1.docs;
        List<QueryDocumentSnapshot> imagesDocuments2 = imageSnapshot2.docs;

        messagesDocuments1.forEach((doc) {
          batch.delete(doc.reference);
        });
        messagesDocuments2.forEach((doc) {
          batch.delete(doc.reference);
        });

        imagesDocuments1.forEach((doc) {
          batch.delete(doc.reference);
        });
        imagesDocuments2.forEach((doc) {
          batch.delete(doc.reference);
        });
        // Commit the batch
        await batch.commit();
        cn.chatRooms.doc(AppConstants.chatRoomModel!.chatRoomId).update({'lastMessage': 'messages deleted', 'chatListTrailingTime': Timestamp.now()});
      } else {
        log('No chat documents found.');
      }

      updateStream(chatRoomId: AppConstants.chatRoomModel!.chatRoomId);
    } catch (e) {
      log('Error clearing chat: $e');
    }
  }

  /////////////////////////////////////////////////////////////////////////////////
  Future<void> deleteChat(ChatsModel targetUser) async {
    try {
      AppConstants.showChatScreen.value = false;

      CollectionReference collection = cn.chatRooms;

      String documentId1 = '${targetUser.uid}_$currentUsersPhone';
      String documentId2 = '${currentUsersPhone}_${targetUser.uid}';

      DocumentSnapshot snapshot1 = await collection.doc(documentId1).get();
      DocumentSnapshot snapshot2 = await collection.doc(documentId2).get();

      if (snapshot1.exists) {
        await collection.doc(documentId1).delete();

        clearChat(targetUser);
      } else if (snapshot2.exists) {
        await collection.doc(documentId2).delete();
        clearChat(targetUser);
      } else {
        log('No matching document found.');
      }
    } catch (e) {
      log('Error deleting document: $e');
    }
  }

  /////////////////////////////////////////////////////////////////////////////////
  void blockUser({required bool isBlock}) async {
    await cn.chatRooms.doc(AppConstants.chatRoomModel!.chatRoomId).update({
      'participants.${currentUsersPhone.toString()}': isBlock == true ? false : true,
    });
  }

  /////////////////////////////////////////////////////////////////////////////////
  Future<void> getModel({
    required UserModel targetUser,
    required ChatsModel chatsModel,
    required Timestamp chatListTrailingTime,
    required String status,
  }) async {
    await getChatRoomModel(chatsModel);
    String isOnline;
    if (chatRoom != null) {
      AppConstants.showChatScreen.value = true;

      if (status == TextConstants.dnd) {
        isOnline = TextConstants.dnd;
      } else {
        isOnline = TextConstants.active;
        isOnline = targetUser.isOnline == true ? 'Online' : DateFormat('HH:mm').format(TimeUtility.parseTimestamp(chatListTrailingTime));
      }
      currentChatDetails = CurrentChatDetailsModel(
          email: targetUser.email!, name: targetUser.name!, phoneNumber: targetUser.phone!, profileImage: targetUser.imageUrl!, isOnline: isOnline, status: targetUser.status!);
    } else {
      log('null is chatroom');
    }
  }

  Future<void> updateStream({required String chatRoomId}) async {
    try {
      var snapshot = await cn.chatRooms.doc(AppConstants.chatRoomModel!.chatRoomId).collection('messages').orderBy('timeMessageSend', descending: true).get();
      streamController.add(snapshot);
    } catch (e) {
      log('Error updating stream: $e');
    }
  }
// String extractFirstAlphabetFromLocalStoreName() {
//   String inputString = localStore.myName!;
//   // Remove leading and trailing whitespaces
//   String trimmedString = inputString.trim();
//   // Check if the string is not empty
//   if (trimmedString.isNotEmpty) {
//     // Extract the first alphabet and convert to uppercase
//     String firstAlphabet = trimmedString.substring(0, 1).toUpperCase();
//     return firstAlphabet;
//   } else {
//     return "";
//   }
// }

  void changeStateChatScreen() => changeState.value = !changeState.value;
  /////////////////////////////////////////////////////////////////////////////////

  void testingTokensAutoUpdating() async {
    cn.generatedTokens.doc('testingTokens').snapshots().listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        String updatedToken = snapshot['token'];
        Timestamp timeStampField = snapshot['timeStampField'];
        DateTime targetDateTime = timeStampField.toDate();
        DateTime twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));

        if (targetDateTime.isAfter(twentyFourHoursAgo)) {
          log('reusing token: $updatedToken');
          token = updatedToken;
          log('Token generated within the last 24 hours');
          // use same token
        } else {
          // log('new token needed :snapshot[token]: $updatedToken');
          // log('Token generated more than 24 hours ago');
          tokenGeneration();
          // generate new token
        }
      }
    });
  }

  /////////////////////////////////////////////////////////////////////////////////
  void tokenGeneration() {
    const role = RtcRole.publisher;

    const expirationInSeconds = 3600;
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final expireTimestamp = currentTimestamp + expirationInSeconds;

    final generateToken = RtcTokenBuilder.build(
      appId: appId,
      appCertificate: appCertificate,
      channelName: channel,
      uid: uid.toString(),
      role: role,
      expireTimestamp: expireTimestamp,
    );
    token = generateToken;
  }

  /////////////////////////////////////////////////////////////////////////////////
  String formatCallDuration(Timestamp startTime, Timestamp endTime) {
    final duration = calculateCallDuration(startTime, endTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours == 0) {
      return '$minutes min $seconds sec';
    } else {
      return '$hours ${TextConstants.hours} $minutes ${TextConstants.minutes} $seconds ${TextConstants.seconds}';
    }
  }

  Duration calculateCallDuration(Timestamp startTime, Timestamp endTime) {
    final start = startTime.toDate();
    final end = endTime.toDate();
    return end.difference(start);
  }
  /////////////////////////////////////////////////////////////////////////////////
}
