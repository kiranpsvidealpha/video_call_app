import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bloc/detect_user_changes.dart';
import 'bloc/fetch_all_users_bloc.dart';
import 'bloc/login_with_email_bloc.dart';
import 'bloc/permission_bloc.dart';
import 'firebase_options.dart';
import 'mainApp/permissionHandler/check_permissions.dart';
import 'reusables/menu_controller.dart';
import 'services/auth_services.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(const PrivateChatApp());
  }, (Object error, StackTrace stack) {
    if (kDebugMode) debugPrint("[App Zone Error ]>>  $error \n[App Zone Stacktrace]: $stack");
  });
}

class PrivateChatApp extends StatefulWidget {
  const PrivateChatApp({super.key});

  @override
  State<PrivateChatApp> createState() => _PrivateChatAppState();
}

class _PrivateChatAppState extends State<PrivateChatApp> with WidgetsBindingObserver {
  final AuthenticationService auth = AuthenticationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => EmailAuthBloc()),
        BlocProvider(create: (context) => PermissionsBloc()),
        BlocProvider(create: (context) => FetchAllUsersBloc()),
        BlocProvider(create: (context) => DetectFirebaseUserChangesBloc()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppMenuController()),
          StreamProvider<User?>.value(initialData: null, value: auth.authStateChanged),
        ],
        child: GetMaterialApp(
          title: 'Hello App',
          darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: ThemeData(fontFamily: 'UniformRounded'),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
