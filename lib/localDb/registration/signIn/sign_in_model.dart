import 'package:hive/hive.dart';
part 'sign_in_model.g.dart';

@HiveType(typeId: 3)
class SignInModel {
  @HiveField(0)
  String? phoneNumber;
  SignInModel({
    this.phoneNumber,
  });

  SignInModel copyWith({
    String? phoneNumber,
  }) {
    return SignInModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
