import 'package:hive/hive.dart';

part 'local_model.g.dart';

@HiveType(typeId: 1)
class LocalModel {
  LocalModel({
    this.signin,
    this.permission,
  });

  @HiveField(0)
  String? signin;

  @HiveField(1)
  String? permission;

  factory LocalModel.fromMap(Map<String, dynamic> data) {
    return LocalModel(
      signin: data['signin'],
      permission: data['permission'],
    );
  }
}
