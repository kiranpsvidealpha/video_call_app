import 'package:cloud_firestore/cloud_firestore.dart';
import 'collection_names.dart';

CollectionNames cn = CollectionNames();

Stream<QuerySnapshot<Object?>>? callHistoryStream() => cn.callHistory.snapshots();

Stream<DocumentSnapshot<Object?>>? callingDialogBoxStream(myDocId) => cn.callHistory.doc(myDocId).snapshots();

Stream<DocumentSnapshot<Object?>>? myProfileListTileStream(myLocalNumber) => cn.users.doc(myLocalNumber).snapshots();

Stream<QuerySnapshot<Object?>> callListTileStream() => cn.callHistory.orderBy('timestamp', descending: true).snapshots();

Stream<QuerySnapshot<Object?>>? chatListTileStream() => cn.chatRooms.orderBy('chatListTrailingTime', descending: true).snapshots();

Stream<QuerySnapshot<Map<String, dynamic>>>? chatViewScreenStream(docId) => cn.chatRooms.doc(docId).collection('messages').orderBy('timeMessageSend', descending: true).snapshots();
