import 'package:flutter/material.dart';

import 'permissions_screen.dart';

// permissions list class
class PermissionList {
  String title;
  String leble;
  IconData icons;
  Function onTap;
  PermissionList({
    required this.title,
    required this.leble,
    required this.icons,
    required this.onTap,
  });
}
// list of permissions elements
List<PermissionList> permissionList = [
  PermissionList(
    title: "Camera permission",
    leble: "Tap to allow camera permission",
    icons: Icons.camera_alt,
    onTap: requestCameraPermission,
  ),
  PermissionList(
    title: "Microphone permission",
    leble: "Tap to allow microphone permission",
    icons: Icons.mic_rounded,
    onTap: requestMicPermission,
  ),
  PermissionList(
    title: "Location permission",
    leble: "Tap to allow location permission",
    icons: Icons.location_on,
    onTap: requestLocationPermission,
  ),
  PermissionList(
    title: "Storage permission",
    leble: "Tap to allow storage permission",
    icons: Icons.storage_sharp,
    onTap: requestStoragePermission,
  ),
];
