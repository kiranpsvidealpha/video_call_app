import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataList {
  final List<UserData> userData;
  UserDataList({required this.userData});
  factory UserDataList.fromQuery(QuerySnapshot snapshot) => UserDataList(
        userData: List<UserData>.from(
          snapshot.docs.map(
            (doc) => UserData.fromSnapshot(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          ),
        ),
      );
}

class UserData {
  final String userId;
  final String username;
  final String fullName;
  final String email;

  UserData({
    required this.userId,
    required this.username,
    required this.email,
    required this.fullName,
  });

  factory UserData.fromSnapshot(Map<String, dynamic> snapshot, String userId) {
    return UserData(
      userId: userId,
      username: snapshot['username'] ?? '',
      email: snapshot['email'] ?? '',
      fullName: snapshot['fullName'] ?? '',
    );
  }

  String userAsString() {
    return "$fullName (${userId.substring(0, 5)})";
  }
}
