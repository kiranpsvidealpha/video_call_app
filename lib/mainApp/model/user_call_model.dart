// ignore_for_file: prefer_null_aware_operators

import 'dart:math';

import 'user_model.dart';

class CallHistoryModel {
  final DateTime timestamp;
  final bool isVoiceCall;
  final bool isIncoming;
  final bool wasMissed;

  final String callId;
  final String userId;
  UserModel? userModel;

  CallHistoryModel({
    required this.timestamp,
    required this.isIncoming,
    required this.isVoiceCall,
    required this.wasMissed,
    this.userModel,
    required this.callId,
    required this.userId,
  });

  factory CallHistoryModel.fromMap(Map<String, dynamic> map) {
    return CallHistoryModel(
      timestamp: DateTime.parse(map['timestamp']),
      isIncoming: map['isIncoming'],
      isVoiceCall: map['isVoiceCall'],
      wasMissed: map['wasMissed'],
      callId: map['callId'],
      userId: map['userId'],
      userModel: map['userModel'] != null ? UserModel.fromMap(map['userModel']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'isIncoming': isIncoming,
      'isVoiceCall': isVoiceCall,
      'wasMissed': wasMissed,
      'callId': callId,
      'userId': userId,
      'userModel': userModel != null ? userModel!.toMap() : null,
    };
  }
}

List<CallHistoryModel> demoCallHistory = List.generate(10, (index) {
  int userNameIndex = Random().nextInt(userNames.length);
  DateTime now = DateTime.now();

  return CallHistoryModel(
    timestamp: DateTime(now.year, now.month, now.day, now.hour, now.minute).subtract(Duration(minutes: index)),
    isVoiceCall: index.isOdd,
    wasMissed: index.isEven,
    isIncoming: index % 4 == 0,
    callId: "chatAppDemoCall$index",
    userId: "chatAppDemoUser$userNameIndex",
  );
});
