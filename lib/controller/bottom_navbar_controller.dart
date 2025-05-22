import 'package:get/get.dart';


class MainBottomNavbarController extends GetxController{
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void changeIndex(int index) {
    _selectedIndex = index;
    update();
  }

  void backToHome() {
    changeIndex(0);
  }
}