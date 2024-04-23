import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../mixins/call_mixin.dart';
import '../../reusable/style.dart';
import '../model/user_model.dart';
import '../../reusable/colors.dart';
import '../../constants/app_constants.dart';
import '../../localDb/registration/signIn/sign_in_box.dart';

class CallInfoScreen extends StatefulWidget {
  const CallInfoScreen({super.key, required this.docId, required this.targetUser});
  final UserModel targetUser;
  final String docId;

  @override
  State<CallInfoScreen> createState() => _CallInfoScreenState();
}

class _CallInfoScreenState extends State<CallInfoScreen> with CallMixin {
  final ScrollController _scrollController = ScrollController();
  final firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>>? documents;
  List<DocumentSnapshot> getData = [];
  DocumentSnapshot? lastDocument;
  QuerySnapshot? querySnapshot;
  QuerySnapshot? totalQuerySnapshot;
  List<String>? docIds = [];
  bool isLoading = false;
  int documentLimit = 15;
  int? totalLength;
  bool hasMore = true;
  String? documentId;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.sizeOf(context).height * 1;
      if (maxScroll - currentScroll <= delta && hasMore && documents != null) {
        fetchDocuments();
      }
    });
  }

  void fetchDocuments() async {
    CollectionReference collection = FirebaseFirestore.instance.collection('callHistory');
    List<String> parts = widget.docId.split('_');
    if (parts.length >= 2) {
      documentId = '${parts[0]}_${parts[1]}';
    }
    QuerySnapshot querySnapshot = await collection.where(FieldPath.documentId, isGreaterThanOrEqualTo: documentId).get();
    List<Map<String, dynamic>> sortedDocuments = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList()
      ..sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
    docIds = querySnapshot.docs.map((doc) => doc.id).toList();
    setState(() {
      isLoading = false;
      documents = sortedDocuments;
    });
  }

  static final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: true,
        iconTheme: const IconThemeData(color: white),
        backgroundColor: bgColor,
        title: const Text(
          'Call Info',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: white),
        ),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            Get.back();
          }
        },
        child: Column(
          children: [
            Container(
              width: size.width,
              color: bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 10),
              child: ListTile(
                leading: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: white,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.targetUser.imageUrl!),
                    radius: 25,
                  ),
                ),
                title: Text(
                  widget.targetUser.name!,
                  style: tStyle16.copyWith(color: white),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.video_call, color: white)),
                    IconButton(
                      onPressed: () async {
                        chatsController.isAudioCalling.value = true;
                        startCalling(
                          isCalling: true,
                          context: context,
                          connectingId: 'fromCallView',
                          subTitle: 'Calling...',
                          title: chatsController.currentChatDetails!.name,
                          documentId: AppConstants.chatRoomModel!.chatRoomId,
                          profileImage: chatsController.currentChatDetails!.profileImage,
                          color: green,
                        );
                      },
                      icon: const Icon(Icons.phone, color: white),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: docIds!.length,
                itemBuilder: ((context, index) {
                  String? callTime;
                  DateTime now = DateTime.now();
                  DateTime dateTime = documents![index]['timestamp'].toDate();
                  Duration difference = now.difference(dateTime);
                  String date = '';
                  if (difference.inMinutes < 60) {
                    callTime = '${difference.inMinutes} min ago';
                  } else {
                    date = DateFormat('yyyy-MM-dd').format(dateTime);
                    String time = DateFormat('HH:mm').format(dateTime);
                    callTime = time;
                  }
                  DateTime today = DateTime.now();
                  bool isToday = DateTime(dateTime.year, dateTime.month, dateTime.day) == DateTime(today.year, today.month, today.day);
                  bool showDateSeparator = index == 0 || date != DateFormat('yyyy-MM-dd').format(documents![index - 1]['timestamp'].toDate());
                  Widget trailingWidget;
                  if (documents![index]['endTime'] != null && documents![index]['startTime'] != null) {
                    trailingWidget = Text(
                      chatsController.formatCallDuration(documents![index]['startTime'], documents![index]['endTime']),
                      style: tStyle12.copyWith(color: greyThree),
                    );
                  } else {
                    trailingWidget = Text('Unanswered', style: tStyle12.copyWith(color: greyThree));
                  }

                  return Column(
                    children: [
                      if (showDateSeparator)
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 15, top: 12),
                          width: double.infinity,
                          color: selectedTileClr,
                          child: Text(
                            isToday ? 'Today' : date,
                            style: tStyleBold16.copyWith(color: black),
                          ),
                        ),
                      ListTile(
                        leading: Icon(
                          documents![index]['callType'] == 'A' ? Icons.call : Icons.video_call,
                        ),
                        title: Text(
                          '${documents![index]['caller'] == currentUsersPhone ? 'Outgoing' : 'Incoming'} ${documents![index]['callType'] == 'A' ? 'Voice' : 'Video'} call at $callTime',
                          style: tStyle14.copyWith(color: greyThree),
                        ),
                        trailing: trailingWidget,
                      ),
                    ],
                  );
                }),
              ),
            ),
            isLoading
                ? Container(
                    width: MediaQuery.sizeOf(context).width,
                    padding: const EdgeInsets.all(5),
                    color: bgColor,
                    child: const Text(
                      'Loading',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
