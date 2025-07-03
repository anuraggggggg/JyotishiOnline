// lib/controllers/bottomController.dart

import 'package:get/get.dart';

class BottomController extends GetxController {
  var currentIndex = 0.obs;

  void setIndex(int index, int dummy) {
    currentIndex.value = index;
    update(); // Optional if you're using GetBuilder
  }
}
