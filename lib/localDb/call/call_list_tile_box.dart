import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'call_list_tile_box.g.dart';

@HiveType(typeId: 7)
class CallListTileBox {
  CallListTileBox({
    this.index,
    this.docId,
    this.title,
    this.caller,
    this.wasMissed,
    this.isAudioCall,
    this.timestamp,
    this.context,
    this.profileImage,
  });

  @HiveField(0)
  int? index;
  @HiveField(1)
  String? docId;
  @HiveField(2)
  String? title;
  @HiveField(3)
  String? caller;
  @HiveField(4)
  bool? wasMissed;
  @HiveField(5)
  bool? isAudioCall;
  @HiveField(6)
  Timestamp? timestamp;
  @HiveField(7)
  BuildContext? context;
  @HiveField(8)
  String? profileImage;
}
