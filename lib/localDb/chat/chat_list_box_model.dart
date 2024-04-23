import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../../mainApp/model/chat_model.dart';
import '../../mainApp/model/chat_room_model.dart';
import '../../mainApp/model/user_model.dart';

part 'chat_list_box_model.g.dart';

@HiveType(typeId: 6)
class ChatListBoxModel {
  ChatListBoxModel({
    this.chatRoomModel,
    this.targetUser,
    this.lastMssg,
    this.chatsModel,
    this.time,
    this.isMessageRead,
  });

  @HiveField(0)
  ChatRoomModel? chatRoomModel;
  @HiveField(1)
  UserModel? targetUser;
  @HiveField(2)
  String? lastMssg;
  @HiveField(3)
  ChatsModel? chatsModel;
  @HiveField(4)
  Timestamp? time;
  @HiveField(5)
  bool? isMessageRead;
}
