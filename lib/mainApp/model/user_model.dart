import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? name;
  String? email;
  String? phone;
  bool? isOnline;
  String? status;
  String? imageUrl;
  String? userLastMessage;
  Timestamp? chatListTrailingTime;
  UserModel({
    this.chatListTrailingTime,
    this.userLastMessage,
    this.isOnline,
    this.imageUrl,
    this.status,
    this.name,
    this.email,
    this.phone,
  });
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      chatListTrailingTime: map['chatListTrailingTime'],
      userLastMessage: map['lastMessage'],
      imageUrl: map['imageProfile'],
      phone: map['phoneNumber'],
      isOnline: map['isOnline'],
      status: map['status'],
      email: map['email'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'imageUrl': imageUrl,
      'isOnline': isOnline,
      'userLastMessage': userLastMessage,
      'chatListTrailingTime': chatListTrailingTime,
    };
  }
}

List<String> userNames = ["Aman Bansal", "Ajay Singh", "Shalini Arora", "Vicky Rajora"];

List<UserModel> demoUsers = List.generate(userNames.length, (index) {
  int userNameIndex = Random().nextInt(userNames.length);
  return UserModel(
    name: userNames[userNameIndex],
    email: "${userNames[userNameIndex].toLowerCase().replaceAll(" ", "")}@chatapp.com",
    phone: "+91 99955 9955$userNameIndex",
  );
});

class GetChatsUsersModel {
  String name;
  String email;
  String phone;
  GetChatsUsersModel({
    required this.name,
    required this.email,
    required this.phone,
  });
  factory GetChatsUsersModel.fromMap(Map<String, dynamic> map) {
    return GetChatsUsersModel(
      name: map['userName'],
      email: map['email'],
      phone: map['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
