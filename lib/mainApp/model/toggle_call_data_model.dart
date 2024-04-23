import 'package:cloud_firestore/cloud_firestore.dart';

class ToggleCallDataModel {
    Timestamp? timestamp;
    bool? isVoiceCall;
    bool? isIncoming;
    bool? wasMissed;
    String? callId;
    String? docId; 
    String? profileImage; 

  ToggleCallDataModel({
   this.profileImage,
   this.timestamp,
   this.isIncoming,
   this.isVoiceCall,
   this.wasMissed, 
   this.callId,
   this.docId,
  });

  factory ToggleCallDataModel.fromMap(Map<String, dynamic> map) {
    return ToggleCallDataModel(
      profileImage:  map['profileImage'],
      timestamp:  map['timestamp'],
      isIncoming: map['isIncoming'],
      isVoiceCall: map['isVoiceCall'],
      wasMissed: map['wasMissed'],
      callId: map['callId'],
      docId: map['docId'], 
    );
  }

 
}
