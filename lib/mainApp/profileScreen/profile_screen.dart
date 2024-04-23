import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../reusable/alert_dialoge.dart';
import '../../services/auth_services.dart';
import 'profile_widgets.dart';
import '../../reusable/style.dart';
import '../../reusable/colors.dart';
import '../../reusable/loader.dart';
import '../../reusable/sized_box_hw.dart';
import '../../reusable/firebase_streams.dart';
import '../controllers/update_profile_controller.dart';
import '../../localDb/registration/signIn/sign_in_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String currentUsersPhone = SignInInfoBox.signinInfoBox.fetchSignin?.phoneNumber ?? "";
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController professionController = TextEditingController();
  final UserProfileController userProfileController = Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    AuthenticationService auth = AuthenticationService();
    return StreamBuilder<DocumentSnapshot>(
      stream: myProfileListTileStream(currentUsersPhone),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LoaderContainerWithMessage(message: "Loading.."));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          userProfileController.updateData(userData!);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      sh50,
                      Obx(
                        () {
                          return Column(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 140,
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 60,
                                        backgroundImage: userProfileController.imageProfileUrl.value.isEmpty
                                            ? const CachedNetworkImageProvider("https://img.icons8.com/arcade/512/name.png")
                                            : CachedNetworkImageProvider(userProfileController.imageProfileUrl.value),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              sh40,
                              Text(
                                userProfileController.name.value,
                                style: TextStyle(color: bgColor, fontSize: 20, fontWeight: bold),
                              ),
                              sh10,
                              Text(
                                userProfileController.profession.value,
                                style: const TextStyle(color: bgColor),
                              )
                            ],
                          );
                        },
                      ),
                      sh40,
                      const Divider(color: grey),
                      ListTile(
                        title: Text(userProfileController.phoneNumber.value),
                        leading: const Icon(
                          Icons.phone,
                          color: bgColor,
                        ),
                      ),
                      NonEditableTextItem(
                        controller: emailController,
                        title: "Email",
                        leadingIcon: Icons.email,
                        initialValue: userProfileController.email.value,
                      ),
                      NonEditableTextItem(
                        controller: professionController,
                        title: "Profession",
                        leadingIcon: Icons.work,
                        initialValue: userProfileController.profession.value,
                      ),
                      InkWell(
                        onTap: () => showLogoutConfirmationDialog(context, auth),
                        child: const NonEditableTextItem(
                          title: "Logout",
                          isLogout: true,
                          leadingIcon: Icons.logout,
                          initialValue: "Logout",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
