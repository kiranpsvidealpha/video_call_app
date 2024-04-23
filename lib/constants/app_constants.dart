import '../mainApp/model/chat_room_model.dart';
import '../mainApp/model/chat_model.dart';
import '../mainApp/model/personal_info_model.dart';
import '../mainApp/model/user_model.dart';
import 'package:get/get.dart';

mixin AppConstants {
  static UserModel? userModel;
  static ChatsModel? chatModel;
  static ChatRoomModel? chatRoomModel;
  static RxString emailToChat = ''.obs;
  static RxString numberToChat = '00'.obs;
  static RxString customAppBarCenterText = ''.obs;
  static RxBool showHelpScreen = false.obs;

  static String latitude = '0';
  static String longitude = '0';
  static String docIdToVideoCall = '';
  static RxBool showChatScreen = false.obs;
  static RxString lastOnline = '00:00'.obs;
  static RxString statusCallInfo = ''.obs;
  static RxString nameToVideoCall = ''.obs;
  static RxString profileImageToVideoCall = ''.obs;
  static RxString userNameToChat = 'Name'.obs;
  static RxString userNameToCall = 'Name'.obs;
  static RxString profileImageToChat = ''.obs;
  static String firstProfilePic = 'https://i.ibb.co/BNCZgB6/profile.png';
  static String lastMessageShowPhoto = '00/upload/Photo/@00#_web_chat/videalpha';
  static String lastMessageShowAudio = '10/upload/Audio/@01#_web_chat/videalpha';
  static String lastMessageShowPdf = '20/upload/Pdf/@02#_web_chat/videalpha';
  static String lastMessagelocation = '30/upload/location/@03#_web_chat/videalpha';
  static String firstProfileBannerPic = 'https://i.ibb.co/Zz87SCq/image-104.png';
  static String lastMessageShowVideo = '30/upload/Video/@00#_web_chat/videalpha';

  static PersonalInfoModel? personalInfoModel;
  static const String hiveBoxKey = "vide_chat_hive_box";
  static const String signUpKey = "sign_up_key";
  static const String signInKey = "sign_in_key";
  static const String chatListTileBoxKey = "chat_list_tile_box_key";
}
