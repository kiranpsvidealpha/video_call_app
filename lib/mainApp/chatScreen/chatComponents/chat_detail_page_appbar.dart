import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../chattingUserProfile/chatting_user_profile.dart';
import '../../../constants/text_constants.dart';
import '../../../constants/app_constants.dart';
import '../../../constants/time_utility.dart';
import '../../../reusable/navigator.dart';
import '../../../reusable/colors.dart';
import '../../mixins/call_mixin.dart';
import '../../mixins/chat_mixin.dart';

class ChatDetailPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ChatDetailPageAppBar({super.key, required this.targetNumber});
  final String targetNumber;
  @override
  State<ChatDetailPageAppBar> createState() => _ChatDetailPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChatDetailPageAppBarState extends State<ChatDetailPageAppBar> with ChatMixin, CallMixin {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.targetNumber).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Container(color: bgColor));
        } else if (snapshot.hasError) {
          return const Center(child: CircularProgressIndicator());
        } else {
          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
          return AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: bgColor,
            flexibleSpace: SafeArea(
              child: Container(
                color: bgColor,
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => removeScreen(context),
                      icon: const Icon(Icons.arrow_back_ios, color: white),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pushSimple(const ChattingUserProfile()),
                        child: Container(
                          color: bgColor,
                          child: Row(
                            children: [
                              buildLeadingPic(userData['imageProfile']),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    userData['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: white),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    userData['isOnline'] == true ? 'Online' : DateFormat('HH:mm').format(TimeUtility.parseTimestamp(userData['chatListTrailingTime'])),
                                    style: TextStyle(color: controller.currentChatDetails!.isOnline == TextConstants.dnd ? red : green, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => chatListTileMenuBox(context, Offset(size.width, 100), AppConstants.chatModel!),
                      child: const Icon(Icons.more_vert, color: white),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
