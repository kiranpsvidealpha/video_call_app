import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsModel {
  String? uid;
  String? lastMessage;
  final bool isOnline;
  final Timestamp lastSeen;
  final String userName;
  final Timestamp lastOnline;
  final String profilePicture;
  ChatsModel({
    this.uid,
    this.lastMessage,
    required this.isOnline,
    required this.lastSeen,
    required this.userName,
    required this.lastOnline,
    required this.profilePicture,
  });

  factory ChatsModel.fromMap(Map<String, dynamic> map) {
    return ChatsModel(
      uid: map['uid'],
      isOnline: map['isOnline'],
      lastSeen: map['lastSeen'],
      userName: map['userName'],
      lastOnline: map['lastOnline'],
      lastMessage: map['lastMessage'],
      profilePicture: map['profilePicture'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'userName': userName,
      'lastOnline': lastOnline,
      'lastMessage': lastMessage,
      'profilePicture': profilePicture,
    };
  }
}
