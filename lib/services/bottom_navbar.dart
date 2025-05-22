import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learnue4app/app.dart';
import 'package:learnue4app/auth/loginpage.dart';
import 'package:learnue4app/auth/registerpage.dart';
import 'package:learnue4app/controller/bottom_navbar_controller.dart';
import 'package:learnue4app/pages/message.dart';
import 'package:learnue4app/pages/profilepage.dart';
import 'package:learnue4app/services/auth_services.dart';
import 'package:learnue4app/utils/app_colors.dart';
import 'package:learnue4app/utils/user_provider.dart';
import 'package:provider/provider.dart';

class MainBottomNavbarScreen extends StatefulWidget {
  const MainBottomNavbarScreen({super.key});

  @override
  State<MainBottomNavbarScreen> createState() => _MainBottomNavbarScreenState();
}

class _MainBottomNavbarScreenState extends State<MainBottomNavbarScreen> {

  final MainBottomNavbarController _navbarController =
      Get.put(MainBottomNavbarController());

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens = [
    const HomePage(),
    const Message(),
  ];

  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else {
      _navbarController.changeIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.user.accessToken.isNotEmpty;

    return Scaffold(
      key: _scaffoldKey,
      body: GetBuilder<MainBottomNavbarController>(builder: (controller) {
        return _screens[controller.selectedIndex];
      }),
      bottomNavigationBar:
          GetBuilder<MainBottomNavbarController>(builder: (controller) {
        return BottomNavigationBar(
          currentIndex: controller.selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.message), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
          ],
        );
      }),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Center(
                  child: Text('More Options',
                      style: TextStyle(color: Colors.white, fontSize: 20))),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      if (!isLoggedIn) ...[
                        ListTile(
                          leading: const Icon(Icons.login),
                          title: const Text('Login'),
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const LoginPage(), transition: Transition.circularReveal, duration: const Duration(milliseconds: 1000));
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_add),
                          title: const Text('Register'),
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const RegisterPage(), transition: Transition.circularReveal, duration: const Duration(milliseconds: 1000));
                          },
                        ),
                      ],
                      if (isLoggedIn) ...[
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Your Profile'),
                          onTap: () {
                            Get.to(
                              const ProfilePage(),
                              transition: Transition.circularReveal,
                              duration: const Duration(milliseconds: 1000),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Logout'),
                          onTap: () {
                            signOutUser(context);
                          },
                        ),
                      ]
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
