import 'dart:async';

import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

class TimerController extends GetxController {
  Timer? secTimer;
  int totalSeconds = 0;
  APIHelper apiHelper = APIHelper();
  int chatId = 0;
  bool endChat = false;

  @override
  void onInit() async {
    _init();
    super.onInit();
  }

  _init() async {
    //startTimer();
  }

  startTimer() {
    totalSeconds = 0;
    secTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      print("total Sec:- $totalSeconds");
      totalSeconds += 1;
      update();
    });
  }

  endChatTime(int seconds, int chatIdd) async {
    try {
      await apiHelper.saveChattingTime(seconds, chatIdd).then((result) {
        if (result.status == "200") {
          global.splashController.currentUser?.walletAmount = result.recordList;

          global.showToast(
            message: 'Chat ended..',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        } else {
          global.showToast(
            message: 'chat not ended',
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        }
      });
      // await global.checkBody().then((result) async {
      //   if (result) {
      //
      //   }
      // });
    } catch (e) {
      print('Exception in endCallRequest : - ${e.toString()}');
    }
  }
}