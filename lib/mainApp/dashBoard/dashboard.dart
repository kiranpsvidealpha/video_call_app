//import 'package:agora_rtc_engine/rtc_engine.dart';
// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../reusables/navigators.dart';
import 'video_call.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<DashboardScreen> {
  final channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;
  ClientRoleType? role = ClientRoleType.clientRoleBroadcaster;
  @override
  void dispose() {
    // dispose input controller
    channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    role = ClientRoleType.clientRoleBroadcaster;
    return SizedBox(
      width: size.width * 0.6,
      height: size.width * 0.4,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              // Wrap your Column with SingleChildScrollView
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: channelController,
                        decoration: InputDecoration(
                          errorText: _validateError ? 'Channel name is mandatory' : null,
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(width: 1),
                          ),
                          hintText: 'Channel name',
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onJoin,
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blueAccent), foregroundColor: MaterialStateProperty.all(Colors.white)),
                          child: const Text('Video Call'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      channelController.text.isEmpty ? _validateError = true : _validateError = false;
    });
    if (channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await pushSimple(context, const VideoCall());
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {}
}
