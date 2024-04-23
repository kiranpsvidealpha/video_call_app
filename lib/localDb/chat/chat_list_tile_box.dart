import 'dart:developer';

import 'package:hive/hive.dart';

import '../../constants/app_constants.dart';
import 'chat_list_box_model.dart';

class ChatListTileBox with AppConstants {
  static const String hiveBoxKey = AppConstants.hiveBoxKey;
  static const String chatListTileBoxKey = AppConstants.chatListTileBoxKey;
  late Box chatListTile;

  ChatListTileBox._() {
    chatListTile = Hive.box(hiveBoxKey);
  }

  static final ChatListTileBox _singleton = ChatListTileBox._();

  factory ChatListTileBox() => _singleton;

  static ChatListTileBox get chatListTileBox => _singleton;

  // Save sign in information to the database
  set saveChatListTile(ChatListBoxModel value) {
    chatListTile.put(chatListTileBoxKey, value).catchError(
      (error, stack) {
        log("Error", name: "Hive sign in info saving error >>", error: error, stackTrace: stack);
      },
    );
  }

  void clearChatListTile() {
    try {
      chatListTile.delete(chatListTileBoxKey);
    } catch (e) {
      log("Error", name: "Hive sign in info clearing error >>", error: e);
    }
  }

  // Retrieve sign in information from the database
  ChatListBoxModel? get fetchChatListTile {
    late ChatListBoxModel? value;
    try {
      value = chatListTile.get(chatListTileBoxKey);
      return value;
    } catch (e) {
      log("Error", name: "Hive sign in info fetching error >>", error: e);
      return value;
    }
  }
}
