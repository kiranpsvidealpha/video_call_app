import 'package:get/get.dart';

class UserProfileController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;
  var phoneNumber = ''.obs;
  var profession = ''.obs;
  var imageProfileUrl = ''.obs;
  
  void updateData(Map<String, dynamic>? userData) {
    if (userData != null) {
      name.value = userData['name'] ?? '';
      email.value = userData['email'] ?? '';
      phoneNumber.value = userData['phoneNumber'] ?? '';
      profession.value = userData['profession'] ?? '';
      imageProfileUrl.value = userData['imageProfile'] ?? '';
    }
  }
}
