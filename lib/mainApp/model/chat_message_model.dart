
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesModel {
  String? text;
  String? messageId;
  final String isSentByMe;
  Timestamp? timeMessageSend;

  MessagesModel({
    this.text,
    this.messageId,
    this.timeMessageSend,
    required this.isSentByMe,
  });
  factory MessagesModel.fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      text: map['text'],
      messageId: map['messageId'],
      isSentByMe: map['isSentByMe'],
      timeMessageSend: map['timeMessageSend'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'messageId': messageId,
      'isSentByMe': isSentByMe,
      'timeMessageSend': timeMessageSend,
    };
  }
}
