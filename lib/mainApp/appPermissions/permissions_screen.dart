import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../reusable/sized_box_hw.dart';
import '../auth/signIn/sign_in_screen.dart';
import '../bloc/permission_bloc.dart';
import '../../reusable/colors.dart';
import '../../constants/assets_constants.dart';

class AppPermissions extends StatefulWidget {
  const AppPermissions({super.key});

  @override
  State<AppPermissions> createState() => _AppPermissionsState();
}

class _AppPermissionsState extends State<AppPermissions> {
  @override
  void initState() {
    context.read<PermissionsBloc>().add(PermissionsStatusRequested());
    super.initState();
  }

  List<bool> statuses = [
    false,
    false,
    false,
    false,
  ];
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: white,
      bottomNavigationBar: BottomAppBar(
        color: bgColor,
        child: ListTile(
          // navigate to signin screen
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignIn(),
              ),
            );
          },
          title: const Text(
            'Next',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            sh40,
            Image.asset(
              AssetsConstants.permissionBg,
              height: height * 0.3,
            ),
            sh40,
            Column(children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: bgColor,
                  child: Icon(
                    Icons.camera_alt,
                    color: white,
                  ),
                ),
                title: const Text(
                  "Camera permission",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text("Tap to allow camera permission"),
                onTap: (() {
                  requestCameraPermission();
                }),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: bgColor,
                  child: Icon(
                    Icons.mic_rounded,
                    color: white,
                  ),
                ),
                title: const Text(
                  "Microphone permission",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text("Tap to allow microphone permission"),
                onTap: (() {
                  requestMicPermission();
                }),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: bgColor,
                  child: Icon(
                    Icons.location_on,
                    color: white,
                  ),
                ),
                title: const Text(
                  "Location permission",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text("Tap to allow location permission"),
                onTap: (() {
                  requestLocationPermission();
                }),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: bgColor,
                  child: Icon(
                    Icons.storage_sharp,
                    color: white,
                  ),
                ),
                title: const Text(
                  "Gallery permission",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text("Tap to allow image gallery permission"),
                onTap: (() {
                  requestStoragePermission();
                }),
              ),
            ])
          ],
        ),
      ),
    );
  }
}

// request for camera permission
Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();
  if (status == PermissionStatus.granted) {
  } else if (status == PermissionStatus.denied) {
  } else if (status == PermissionStatus.permanentlyDenied) {
    await openAppSettings();
  }
}

// request for microphone permission
Future<void> requestMicPermission() async {
  final status = await Permission.microphone.request();
  if (status == PermissionStatus.granted) {
  } else if (status == PermissionStatus.denied) {
  } else if (status == PermissionStatus.permanentlyDenied) {
    await openAppSettings();
  }
}

// request for location permission
Future<void> requestLocationPermission() async {
  final status = await Permission.locationWhenInUse.request();
  if (status == PermissionStatus.granted) {
  } else if (status == PermissionStatus.denied) {
  } else if (status == PermissionStatus.permanentlyDenied) {
    await openAppSettings();
  }
}

// request for storage permission
Future<void> requestStoragePermission() async {
  final status = await Permission.mediaLibrary.request();
  if (status == PermissionStatus.granted) {
  } else if (status == PermissionStatus.denied) {
  } else if (status == PermissionStatus.permanentlyDenied) {
    await openAppSettings();
  }
}
