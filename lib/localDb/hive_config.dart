import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'permisson/local_model.dart';
import '../constants/app_constants.dart';
import 'registration/signIn/sign_in_model.dart';

class AppHiveConfig {
  AppHiveConfig._();

  static Future<void> init() async {
    if (!kIsWeb) {
      Directory directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
    }

    Hive.registerAdapter(LocalModelAdapter());
    Hive.registerAdapter(SignInModelAdapter());

    // Initialize Hive with an encryption key
    await Future.wait([
      Hive.openBox(AppConstants.hiveBoxKey),
    ]);
  }
}
