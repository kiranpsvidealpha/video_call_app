import 'dart:developer';

import 'package:hive/hive.dart';

import 'local_model.dart';

class LocalBox {
  static const String hiveBoxKey = "private_chat_hive_box_key";
  static const String localBoxKey = "local_data_key";
  late Box _localBox;
  LocalBox._() {
    _localBox = Hive.box(hiveBoxKey);
  }
  static final LocalBox _singleton = LocalBox._();
  factory LocalBox() => _singleton;

  ///for public use
  static LocalBox get localBox => _singleton;

  ///save data to db
  setDetails(LocalModel value) {
    _localBox.put(localBoxKey, value).catchError(
      (error, stack) {
        log("Error", name: "Hive saving error >>", error: error, stackTrace: stack);
      },
    );
  }

  ///fetch data from db
  LocalModel get localData {
    LocalModel value = LocalModel.fromMap({});
    try {
      value = _localBox.get(localBoxKey);
      return value;
    } catch (e) {
      log("Error", name: "Hive fetching error >>", error: e);
      return value;
    }
  }
}
