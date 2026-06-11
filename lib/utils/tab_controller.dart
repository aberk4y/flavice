import 'package:flutter/foundation.dart';

class TabControllerManager {
  static final ValueNotifier<int> currentTab = ValueNotifier<int>(0);

  static final ValueNotifier<int> refreshMenu = ValueNotifier<int>(0);

  static final ValueNotifier<int> refreshShopping = ValueNotifier<int>(0);

  static void changeTab(int index) {
    currentTab.value = -1;
    currentTab.value = index;
  }

  static void notifyMenuChanged() {
    refreshMenu.value++;
  }

  static void notifyShoppingChanged() {
    refreshShopping.value++;
  }
}
