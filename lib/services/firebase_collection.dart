import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class CollectionNames {
  CollectionReference userDb = db.collection("users");
}


