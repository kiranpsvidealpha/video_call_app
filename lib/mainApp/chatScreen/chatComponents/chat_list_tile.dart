import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import '../../../constants/app_constants.dart';
import '../../../constants/time_utility.dart';
import '../../../reusable/sized_box_hw.dart';
import '../../model/chat_room_model.dart';
import '../../../reusable/colors.dart';
import '../../../reusable/style.dart';
import '../../mixins/chat_mixin.dart';
import '../../model/chat_model.dart';
import '../../model/user_model.dart';
import '../chatting_screen.dart';

class ChatListTile extends StatefulWidget {
  final ChatRoomModel chatRoomModel;
  final UserModel targetUser;
  final ChatsModel chatsModel;
  final String lastMssg;
  final bool isMessageRead;
  final Timestamp time;
  const ChatListTile({
    super.key,
    required this.time,
    required this.targetUser,
    required this.chatsModel,
    required this.chatRoomModel,
    required this.isMessageRead,
    required this.lastMssg,
  });
  @override
  ChatListTileState createState() => ChatListTileState();
}

class ChatListTileState extends State<ChatListTile> with ChatMixin {
  @override
  Widget build(BuildContext context) {
    DateTime dateTime = TimeUtility.parseTimestamp(widget.time);
    return InkWell(
      splashColor: selectedTileClr,
      onTap: () async {
        await controller.getModel(
          chatListTrailingTime: widget.time,
          chatsModel: widget.chatsModel,
          status: widget.targetUser.status!,
          targetUser: widget.targetUser,
        );
        Get.to(() => ChattingScreen(targetNumber: widget.targetUser.phone.toString()), transition: Transition.rightToLeft);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Container(
          decoration: BoxDecoration(
            color: transparent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Stack(
                      children: [
                        buildLeadingPic(widget.targetUser.imageUrl.toString()),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.targetUser.isOnline == true ? green : transparent,
                              border: widget.targetUser.isOnline == true ? Border.all(color: white, width: 1.0) : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    sw16,
                    Expanded(
                      child: Container(
                        color: transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.targetUser.name.toString(), style: tStyle20.copyWith(color: black)),
                            const SizedBox(height: 6),
                            widget.chatRoomModel.lastMessage! == AppConstants.lastMessageShowPhoto
                                ? const Icon(Icons.image, color: black)
                                : widget.chatRoomModel.lastMessage! == AppConstants.lastMessagelocation
                                    ? const Icon(Icons.location_on, color: black)
                                    : widget.chatRoomModel.lastMessage! == AppConstants.lastMessageShowAudio
                                        ? const Icon(Icons.audio_file, color: black)
                                        : widget.chatRoomModel.lastMessage! == AppConstants.lastMessageShowPdf
                                            ? const Icon(Icons.picture_as_pdf, color: black)
                                            : widget.chatRoomModel.lastMessage! == AppConstants.lastMessageShowVideo
                                                ? const Icon(Icons.play_arrow, color: black)
                                                : Text(widget.chatRoomModel.lastMessage!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: tStyle14.copyWith(
                                                        color: widget.isMessageRead ? bgColor : greyTwo, fontWeight: widget.isMessageRead ? FontWeight.bold : FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(DateFormat('HH:mm').format(dateTime), style: tStyle14.copyWith(color: greyTwo)),
            ],
          ),
        ),
      ),
    );
  }
}
