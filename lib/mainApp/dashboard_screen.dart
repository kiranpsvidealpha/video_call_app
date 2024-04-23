import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../constants/text_constants.dart';
import '../reusable/anim_search_widget.dart';
import 'chatScreen/chat_screen.dart';
import '../reusable/colors.dart';
import 'callScreen/call_screen.dart';
import '../services/auth_services.dart';
import 'controllers/chats_controller.dart';
import 'profileScreen/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State {
  final AuthenticationService auth = AuthenticationService();
  var pageController = PageController();
  ChatsController chatsController = Get.put(ChatsController());
  bool _isFirstBuild = true;
  int selectedTab = 0;
  final List pageTiles = [
    TextConstants.chat,
    TextConstants.call,
    TextConstants.profile,
  ];

  changeTab(int index) {
    setState(() {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
      selectedTab = index;
      chatsController.expandableSearchBar.value = false;
      chatsController.toggle = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstBuild) {
      _isFirstBuild = false;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: bgColor,
        title: Obx(() => chatsController.expandableSearchBar.value == false
            ? Text(
                pageTiles[selectedTab],
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: white),
              )
            : const SizedBox.shrink()),
        actions: selectedTab == 0
            ? [searchBarWidget(searchController: chatsController.searchChat)]
            : selectedTab == 1
                ? [searchBarWidget(searchController: chatsController.searchCallLogs)]
                : [],
      ),
      body: SafeArea(
        child: PageView(
          controller: pageController,
          children: const [
            ChatScreen(),
            CallScreen(),
            ProfileScreen(),
          ],
          onPageChanged: (index) {
            setState(() {
              selectedTab = index;
            });
          },
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: black),
        child: BottomNavigationBar(
          currentIndex: selectedTab,
          onTap: (index) => changeTab(index),
          selectedItemColor: selectedClr,
          unselectedItemColor: white,
          elevation: 0,
          items: [
            bottomNavigationBarItem(index: 0, path: 'message'),
            bottomNavigationBarItem(index: 1, path: 'call'),
            bottomNavigationBarItem(index: 2, path: 'profile'),
          ],
        ),
      ),
    );
  }

  Widget searchBarWidget({required TextEditingController searchController}) {
    return Obx(() => AnimSearchBar(
          rtl: true,
          width: chatsController.expandableSearchBar.value == true ? 350 : 20,
          textFieldIconColor: black,
          textController: searchController,
          onSubmitted: (e) {
            chatsController.expandableSearchBar.value = false;
            if (e.isEmpty) {
              chatsController.isSearchingChats.value = false;
            } else {
              chatsController.isSearchingChats.value = true;
            }
          },
          closeSearchOnSuffixTap: true,
          boxShadow: false,
          searchIconColor: white,
          color: bgColor,
          suffixIcon: const Icon(
            Icons.close,
            size: 20,
            color: black,
          ),
          onSuffixTap: () {
            chatsController.isSearchingChats.value = false;
            setState(() {
              chatsController.expandableSearchBar.value = false;
            });
          },
        ));
  }

  BottomNavigationBarItem bottomNavigationBarItem({required String path, required int index}) => BottomNavigationBarItem(
      icon: SvgPicture.asset(
        'assets/image/svg/$path.svg',
        height: 25,
        colorFilter: ColorFilter.mode(selectedTab == index ? blue : grey, BlendMode.srcIn),
      ),
      label: '');
}
