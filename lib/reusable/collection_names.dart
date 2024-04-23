import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class CollectionNames {
  CollectionReference staticConstants = db.collection('staticConstants');
  CollectionReference callHistory = db.collection('callHistory');
  CollectionReference generatedTokens = db.collection('generatedTokens');
  CollectionReference chatRooms = db.collection('chatRooms');
  CollectionReference users = db.collection('users');
}
