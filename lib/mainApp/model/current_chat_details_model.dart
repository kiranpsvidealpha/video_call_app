class CurrentChatDetailsModel {
  final String profileImage;
  final String phoneNumber;
  final String isOnline;
  final String status;
  final String email;
  final String name;

  CurrentChatDetailsModel({
    required this.email,
    required this.name,
    required this.status,
    required this.isOnline,
    required this.phoneNumber,
    required this.profileImage,
  });
  factory CurrentChatDetailsModel.fromMap(Map<String, dynamic> map) {
    return CurrentChatDetailsModel(
      profileImage: map['profileImage'],
      phoneNumber: map['phoneNumber'],
      isOnline: map['isOnline'],
      status: map['status'],
      email: map['email'],
      name: map['name'],
    );
  }
}
