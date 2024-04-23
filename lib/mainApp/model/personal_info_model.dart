class PersonalInfoModel {
  String? myName;
  String? myEmailId;
  String? myMobileNumber;
  String? myProfileImage;
  String? myBackgroundImage;
  String? myStatus;

  PersonalInfoModel({
    this.myName,
    this.myEmailId,
    this.myMobileNumber,
    this.myProfileImage,
    this.myBackgroundImage,
    this.myStatus,
  });

  factory PersonalInfoModel.fromMap(Map<String, dynamic> map) {
    return PersonalInfoModel(
      myName: map['myName'],
      myEmailId: map['myEmailId'],
      myMobileNumber: map['myMobileNumber'],
      myProfileImage: map['myProfileImage'],
      myBackgroundImage: map['myBackgroundImage'],
      myStatus: map['myStatus'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'myName': myName,
      'myEmailId': myEmailId,
      'myMobileNumber': myMobileNumber,
      'myProfileImage': myProfileImage,
      'myBackgroundImage': myBackgroundImage,
      'myStatus': myStatus,
    };
  }
}
