import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../localDb/registration/signIn/sign_in_box.dart';
import '../controllers/chats_controller.dart';
import '../../constants/text_constants.dart';
import '../../constants/app_constants.dart';
import '../../reusable/text_font_size.dart';
import '../../constants/time_utility.dart';
import '../../reusable/sized_box_hw.dart';
import '../../reusable/colors.dart';
import '../../reusable/style.dart';
import '../model/chat_model.dart';

mixin ChatMixin {
  ChatsController controller = Get.put(ChatsController());

  Widget chatListTile({
    required String title,
    required int index,
    required bool isOnline,
    required String lastMssg,
    required Timestamp trailingTime,
    required String profileImage,
  }) {
    DateTime dateTime = TimeUtility.parseTimestamp(trailingTime);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
      decoration: BoxDecoration(
        color: grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Obx(
        () => DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: black),
                padding: const EdgeInsets.all(3),
                child: Stack(
                  children: [
                    buildLeadingPic(profileImage),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? green : transparent,
                          border: isOnline ? Border.all(color: white, width: 1.0) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              sw20,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontSize: 13, color: index == controller.isTapped.value ? white : black),
                    ),
                    lastMssg == AppConstants.lastMessageShowPhoto
                        ? Icon(Icons.image, color: index == controller.isTapped.value ? white : black)
                        : lastMssg == AppConstants.lastMessageShowAudio
                            ? Icon(Icons.audio_file, color: index == controller.isTapped.value ? white : black)
                            : lastMssg == AppConstants.lastMessageShowPdf
                                ? Icon(Icons.picture_as_pdf, color: index == controller.isTapped.value ? white : black)
                                : Text(
                                    lastMssg,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 10, color: index == controller.isTapped.value ? white : black),
                                  ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('HH:mm').format(dateTime),
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 9.5, color: index == controller.isTapped.value ? white : black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLeadingPic(String image) => SizedBox(
        height: 50,
        width: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(300.0),
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: image,
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      );

  void chatListTileMenuBox(
    BuildContext context,
    Offset position,
    ChatsModel targetChat,
  ) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          position,
          position,
        ),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: [
              const Icon(Icons.backspace_sharp, color: black),
              sw15,
              Text(
                'Clear Chat',
                style: tStyle18.copyWith(color: black),
              ),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: [
              const Icon(Icons.delete_forever_sharp, color: black),
              sw15,
              Text(
                'Delete Chat',
                style: tStyle18.copyWith(color: black),
              ),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Row(
            children: [
              Obx(() => Icon(controller.isBlockContact.value ? Icons.block : Icons.done, color: red)),
              sw15,
              Obx(() => Text(
                    controller.isBlockContact.value ? TextConstants.blockContact : TextConstants.unBlockContact,
                    style: const TextStyle(color: red),
                  )),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value != null) {
        if (value == 0) {
          bool proceed = await showConfirmationDialog(context);
          if (proceed) {
            controller.clearChat(targetChat);
          }
        } else if (value == 1) {
          bool proceed = await showConfirmationDialog(context);
          if (proceed) {
            await controller.deleteChat(targetChat);
          }
        } else if (value == 2) {
          bool proceed = await showConfirmationDialog(context);
          if (proceed) {
            controller.blockUser(isBlock: controller.isBlockContact.value);
          }
        }
      }
    });
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: SizedBox(
                height: 160,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Are you sure you want to Proceed?",
                        style: TextStyle(fontSize: fontSize15),
                      ),
                    ),
                    sh20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("No", style: TextStyle(color: green)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            Get.back();
                          },
                          child: const Text("Yes", style: TextStyle(color: red)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  static String messageIdentifier() {
    final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";
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

  Widget selectableText(
    String text,
    bool isSentByCurrentUser,
    Size size,
  ) {
    String firstHalf;
    String secondHalf;
    RxBool flag = true.obs;
    if (text.length > 50) {
      firstHalf = text.substring(0, 50);
      secondHalf = text.substring(50, text.length);
    } else {
      firstHalf = text;
      secondHalf = "";
    }
    return secondHalf == ''
        ? Text(
            firstHalf,
            style: TextStyle(
              color: isSentByCurrentUser ? black : white,
            ),
          )
        : Obx(
            () => Container(
              width: size.width * 0.7,
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Wrap(
                children: [
                  SelectableText(flag.value ? ('$firstHalf...') : (firstHalf + secondHalf), maxLines: null, style: tStyle14.copyWith(color: isSentByCurrentUser ? black : white)),
                  InkWell(
                    onTap: () {
                      flag.value = !flag.value;
                    },
                    child: Text(
                      flag.value ? 'show more' : 'show less',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSentByCurrentUser ? black : white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget builCircularIndicator() => const Center(child: SizedBox(height: 5, child: CircularProgressIndicator()));

  Widget loadingBar() {
    return const LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(bgColor),
      backgroundColor: secondaryColor,
    );
  }
}
