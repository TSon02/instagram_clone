import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/add_post_screen.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/search_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _pageIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // print('init state');
    addData();
    // FirestoreMethods().getFirebaseMessagingToken();

    // FirestoreMethods().updateActiveStatus(true);

    SystemChannels.lifecycle.setMessageHandler(
      (message) async {
        // print(message);

        if (FirebaseAuth.instance.currentUser != null) {
          if (message.toString().contains('paused')) {
            await FirestoreMethods().updateActiveStatus(false);
          }

          if (message.toString().contains('resumed')) {
            await FirestoreMethods().updateActiveStatus(true);
          }
        }

        return Future.value(message);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  Future<void> addData() async {
    // print('refresh data for user');
    await Provider.of<UserProvider>(context, listen: false).refreshUser();

    // await FirestoreMethods().getFirebaseMessagingToken();
    await FirestoreMethods().updateActiveStatus(true);
  }

  void navigationTapped(int index) {
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          const FeedScreen(),
          const SearchScreen(),
          const AddPostScreen(),
          const Text('4'),
          FutureBuilder(
              future: addData(),
              builder: (context, snapshot) {
                return ProfileScreen(
                  uid: Provider.of<UserProvider>(context).getUser.uid,
                );
              })
        ],
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        activeColor: primaryColor,
        currentIndex: _pageIndex,
        onTap: (value) {
          navigationTapped(value);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
        ],
      ),
    );
  }
}
