import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../localDb/registration/signIn/sign_in_box.dart';
import '../../constants/assets_constants.dart';
import '../../reusable/collection_names.dart';
import '../model/chat_message_model.dart';
import '../mixins/call_mixin.dart';
import '../../reusable/style.dart';
import '../../reusable/colors.dart';
import '../../reusable/navigator.dart';
import '../../reusable/sized_box_hw.dart';
import '../../constants/app_constants.dart';
import '../controllers/chats_controller.dart';
import '../controllers/sent_message_controller.dart';

Widget buildNoResult() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(
        child: Image.asset(AssetsConstants.noCallHistory),
      ),
      const SizedBox(height: 10),
      const Text('No Result Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    ],
  );
}

Widget iconCreation(IconData icons, Color color, String text, BuildContext ctx) {
  return InkWell(
    child: Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color,
          child: Icon(icons, size: 25, color: white),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        )
      ],
    ),
  );
}

Widget bottomSheet(BuildContext context, bool showRecordingAudioToSend) {

  return SizedBox(
    height: 150,
    width: MediaQuery.sizeOf(context).width,
    child: Card(
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const SizedBox(width: 30),
            GestureDetector(
              onTap: () => pushSimple(const CustomAlertDialog()),
              child: iconCreation(Icons.location_on, red, "Location", context),
            ),
          ],
        ),
      ),
    ),
  );
}

class LocationAttachment extends StatefulWidget {
  const LocationAttachment({super.key, required this.lat, required this.long});
  final String? lat;
  final String? long;
  @override
  State<LocationAttachment> createState() => LocationAttachmentState();
}

class LocationAttachmentState extends State<LocationAttachment> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => MapsLauncher.launchCoordinates(double.parse(widget.lat!), double.parse(widget.long!)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: SizedBox(
          height: 120,
          width: 220,
          child: Image.asset('assets/image/maps_images.png'),
        ),
      ),
    );
  }
}

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({super.key});

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  String address = "null";
  String autocompletePlace = "null";
  CollectionNames cn = CollectionNames();
  ChatsController chatsController = ChatsController();
  TextEditingController controller = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  CameraPosition initialCameraPosition = const CameraPosition(target: LatLng(59.45, 11.0), zoom: 13);

  final List<Marker> _markers = <Marker>[];
  bool showMaps = false;
  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _markers.add(const Marker(markerId: MarkerId('myLocation'), position: LatLng(59.45, 11.0)));
    if (_markers.isNotEmpty) {
      setState(() {});
    }
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      log('Location permission granted');
    } else {
      log('Location permission denied');
    }
  }

  SentMessageController sentMessageController = Get.put(SentMessageController());
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: initialCameraPosition,
              myLocationEnabled: true,
              onTap: (e) {
                AppConstants.latitude = e.latitude.toString();
                AppConstants.longitude = e.longitude.toString();
                setState(() {});
              },
              markers: Set<Marker>.of(_markers),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";
            MessagesModel onSubmitMessage = MessagesModel(
              messageId: CallMixin.messageIdentifier(),
              timeMessageSend: Timestamp.now(),
              isSentByMe: currentUsersPhone,
              text: '',
            );

            cn.chatRooms.doc(AppConstants.chatRoomModel!.chatRoomId).collection('messages').doc(onSubmitMessage.messageId).set(onSubmitMessage.toMap());
            cn.chatRooms
                .doc(AppConstants.chatRoomModel!.chatRoomId)
                .update({'lastMessage': AppConstants.lastMessagelocation, 'chatListTrailingTime': onSubmitMessage.timeMessageSend});
            AppConstants.latitude = '0';
            AppConstants.longitude = '0';
            removeScreen(context);
            removeScreen(context);
          },
          child: const Text('Share'),
        ),
      ],
    );
  }
}

class ContactInfoListButton extends StatelessWidget {
  const ContactInfoListButton({
    super.key,
    required this.width,
    required this.icon,
    required this.label,
    required this.isDeleteChat,
  });
  final bool isDeleteChat;
  final double width;
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: width,
        height: 40,
        decoration: BoxDecoration(
            color: isDeleteChat == true ? pinkTwo : white,
            border: Border.all(
              color: pinkTwo,
            ),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            sw10,
            Icon(
              icon,
              color: isDeleteChat == true ? white : pinkTwo,
            ),
            sw10,
            Text(label, style: tStyle13.copyWith(color: isDeleteChat == true ? white : pinkTwo))
          ],
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////ContactInfoTile
/////////////////////////////////////////////////////////////////////////////////////////////////////
class ContactInfoTile extends StatelessWidget {
  const ContactInfoTile({
    super.key,
    required this.width,
    required this.infoText,
    required this.label,
  });
  final double width;
  final String infoText;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(label, style: tStyle14.copyWith(color: black)),
        ),
        sh10,
        Container(
          width: width,
          height: 40,
          decoration: BoxDecoration(
            color: lightBlueColor,
            boxShadow: [
              BoxShadow(
                color: black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 18),
            child: Text(infoText, style: tStyle13.copyWith(color: black)),
          ),
        )
      ],
    );
  }
}
