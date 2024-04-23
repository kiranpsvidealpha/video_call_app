import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'localDb/call/call_list_tile_box.dart';
import 'localDb/chat/chat_list_box_model.dart';
import 'localDb/hive_config.dart';
import 'services/auth_services.dart';
import 'reusable/menu_controller.dart';
import 'mainApp/splashScreen/splash_screen.dart';
import 'mainApp/network/no_internet.dart';
import 'services/life_cycle_manager.dart';
import 'mainApp/bloc/permission_bloc.dart';
import 'mainApp/controllers/auth_controller.dart';
import 'mainApp/dashboard_screen.dart';

late Box box;
late Box chatListBox;
late Box callListBox;
late Box settingsBox;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate();
  await Hive.initFlutter();
  Hive.registerAdapter(ChatListBoxModelAdapter());
  chatListBox = await Hive.openBox('chatbox');
  //
  Hive.registerAdapter(CallListTileBoxAdapter());
  callListBox = await Hive.openBox<CallListTileBox>('callbox');
  AuthenticationService().checkUserState();
  Get.put(AuthController());
  await AppHiveConfig.init();
  await FirebaseAppCheck.instance.activate();
  runApp(const MaterialApp(home: PrivateChatApp()));
}

class PrivateChatApp extends StatefulWidget {
  const PrivateChatApp({super.key});

  @override
  State<PrivateChatApp> createState() => _PrivateChatAppState();
}

class _PrivateChatAppState extends State<PrivateChatApp> with WidgetsBindingObserver {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final AuthenticationService auth = AuthenticationService();

  String release = "";
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    bool isOnline = state == AppLifecycleState.resumed;
    updateOnlineStatus(isOnline);
  }

  void updateOnlineStatus(bool isOnline) async {
    if (isLoggedIn == true) {
      await FirebaseFirestore.instance.collection('users').doc(auth.currentUser()!.phoneNumber).update({'isOnline': isOnline, 'chatListTrailingTime': Timestamp.now()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NetworkBloc()),
        BlocProvider(create: (context) => PermissionsBloc()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppMenuController()),
          StreamProvider<User?>.value(initialData: null, value: auth.authStateChanged),
        ],
        child: LifeCycleObserver(
          child: GetMaterialApp(
            title: 'Hello App',
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'UniformRounded'),
            home: isLoggedIn == true ? const DashboardScreen() : const SplashScreen(),
          ),
        ),
      ),
    );
  }
}

//deepLinking: link:-https://vide-chats.web.app/app/
