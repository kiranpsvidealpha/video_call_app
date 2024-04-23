// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localDb/registration/signIn/sign_in_box.dart';
import '../../../localDb/call/call_list_tile_box.dart';
import '../../../main.dart';
import '../../controllers/call_screen_controller.dart';
import '../../../reusable/firebase_streams.dart';
import '../../../services/firebase_helper.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../../reusable/navigator.dart';
import '../../model/user_call_model.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/loader.dart';
import '../../../reusable/style.dart';
import '../../model/user_model.dart';
import '../../mixins/call_mixin.dart';
import '../call_info_screen.dart';

typedef SearchCallback = void Function(String query);

class CallListTileWidget extends StatefulWidget {
  const CallListTileWidget({super.key});

  @override
  State<CallListTileWidget> createState() => _CallListTileWidgetState();
}

class _CallListTileWidgetState extends State<CallListTileWidget> with CallMixin {
  List<CallHistoryModel> filteredCallHistory = [];
  CallScreenController controller = Get.put(CallScreenController());
  final TextEditingController searchController = TextEditingController();
  final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";
  void filterSearchResults(String query) {
    filteredCallHistory.clear();
    if (query.isEmpty) {
      filteredCallHistory.addAll(demoCallHistory);
    } else {
      filteredCallHistory = demoCallHistory.where((callHistory) {
        final name = callHistory.userModel?.name!.toLowerCase();
        return name != null && name.contains(query.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    filteredCallHistory.addAll(demoCallHistory);

    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String? docId;
  bool? callOff;
  Timestamp? timestamp;

  CallListTileBox dataToSave = CallListTileBox();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width,
      child: Column(
        children: [
          sh10,
          Expanded(
            child: filteredCallHistory.isEmpty
                ? Align(
                    alignment: Alignment.center,
                    child: Text('Not Found', style: tStyleBold25.copyWith(color: black)),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: callListTileStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: LoaderContainerWithMessage(
                            message: 'Loading...',
                          ),
                        );
                      }
                      QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                      List<QueryDocumentSnapshot> filteredDocs = chatRoomSnapshot.docs.where((document) => document.id.contains(currentUsersPhone)).toList();
                      controller.filteredDocuments = filteredDocs;
                      if (filteredDocs.isEmpty) {
                        return buildNoCallHistory();
                      }
                      String otherPhoneNumber = '';
                      bool documentExists = snapshot.data!.docs.any((doc) {
                        if (doc.id.contains(currentUsersPhone)) {
                          String docDateateStamp = doc.id.split('_')[2];
                          String timestampStr = doc.id.split('_')[3];
                          List<String> idParts = doc.id.split('_');
                          docId = doc.id;
                          for (String part in idParts) {
                            if (part.isNotEmpty && part != currentUsersPhone) {
                              otherPhoneNumber = part;
                              break;
                            }
                          }
                          String caller = doc['caller'];
                          timestamp = doc['timestamp'];
                          callOff = doc['callOff'];
                          DateTime documentDate = DateTime.parse('$docDateateStamp $timestampStr');
                          Duration timeDifference = DateTime.now().difference(documentDate);
                          return timeDifference.inMinutes <= 1 && caller != currentUsersPhone;
                        } else {
                          return false;
                        }
                      });

                      if (documentExists == true && !controller.dialogShown && callOff == false) {
                        FirebaseHelper.getUserModelById(otherPhoneNumber).then(
                          (userModel) {
                            if (userModel != null) {
                              String profileImage = userModel.imageUrl!;
                              String name = userModel.name!;
                              BuildContext dialogContext = context;

                              receiveCallingDialogBox(
                                docId: docId!,
                                title: name,
                                dialogContext,
                                isCalling: false,
                                profileImage: profileImage,
                                subTitle: 'In-Comming Call...',
                                color: green,
                              );
                            } else {}
                          },
                        );
                      }
                      return ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemCount: controller.filteredDocuments.length,
                        itemBuilder: (context, index) {
                          String docId = controller.filteredDocuments[index].id;
                          List<String> parts = docId.split('_');
                          parts.remove(currentUsersPhone);
                          String otherPhoneNumber = parts.isNotEmpty ? parts[0] : '';
                          String? documentId;
                          if (parts.length >= 2) {
                            documentId = '${parts[0]}_${parts[1]}';
                          }
                          return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(otherPhoneNumber),
                            builder: (context, userData) {
                              if (userData.data != null) {
                                final document = snapshot.data!.docs[index];
                                UserModel targetUser = userData.data as UserModel;

                                dataToSave = CallListTileBox(
                                  isAudioCall: document['callType'] == 'A' ? true : false,
                                  profileImage: targetUser.imageUrl.toString(),
                                  timestamp: document['timestamp'],
                                  wasMissed: document['received'],
                                  caller: document['caller'],
                                  title: targetUser.name!,
                                  context: context,
                                  docId: docId,
                                  index: index,
                                );
                                callListBox.put('callbox', dataToSave);
                                return InkWell(
                                  splashColor: selectedTileClr,
                                  onTap: () => pushSimple(CallInfoScreen(docId: docId, targetUser: targetUser)),
                                  child: buildCallListTile(
                                    isAudioCall: document['callType'] == 'A' ? true : false,
                                    profileImage: targetUser.imageUrl.toString(),
                                    timestamp: document['timestamp'],
                                    wasMissed: document['received'],
                                    caller: document['caller'],
                                    title: document['caller'],
                                    context: context,
                                    docId: docId,
                                    index: index,
                                    size: size,
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
