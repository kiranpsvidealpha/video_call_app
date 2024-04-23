import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String name;
  final bool isOnline;
  String? lastMessage;
  final String chatRoomId;
  final String phoneNumber;
  final String imageProfile;
  Map<String, dynamic>? participants;
  final Timestamp chatListTrailingTime;

  ChatRoomModel({
    this.lastMessage,
    this.participants,
    required this.name,
    required this.isOnline,
    required this.chatRoomId,
    required this.phoneNumber,
    required this.imageProfile,
    required this.chatListTrailingTime,
  });
  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    return ChatRoomModel(
      name: map['name'],
      isOnline: map['isOnline'],
      chatRoomId: map['chatRoomId'],
      phoneNumber: map['phoneNumber'],
      lastMessage: map['lastMessage'],
      imageProfile: map['imageProfile'],
      participants: map['participants'],
      chatListTrailingTime: map['chatListTrailingTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'isOnline': isOnline,
      'chatRoomId': chatRoomId,
      'phoneNumber': phoneNumber,
      'lastMessage': lastMessage,
      'participants': participants,
      'imageProfile': imageProfile,
      'chatListTrailingTime': chatListTrailingTime,
    };
  }
}
