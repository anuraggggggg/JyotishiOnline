// ignore_for_file: avoid_print, deprecated_member_use

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/customer_support_controller.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';


class HomeCheckController extends FullLifeCycleController
    with FullLifeCycleMixin {
  // final HomeController homeController = Get.find<HomeController>();

  // Mandatory

  @override
  void onDetached() {
    // homeController.videoPlayerController!.dispose();

    print('HomeController - onDetached called');
  }

  // Mandatory
  @override
  void onInactive() async {
    }

  // Mandatory
  @override
  void onPaused() {
    print('HomeController - onPaused called');
  }

  // Mandatory
  @override
  void onResumed() async {
    BottomNavigationController bottomController =
        Get.find<BottomNavigationController>();
    await bottomController.getLiveAstrologerList();
    global.sp = await SharedPreferences.getInstance();
    CustomerSupportController customerSupportController =
        Get.find<CustomerSupportController>();
    if (customerSupportController.tickitIndex != null) {
      global.showOnlyLoaderDialog(Get.context);
      await customerSupportController.getCustomerTickets();
      await customerSupportController.getCustomerReview(
          customerSupportController
              .ticketList[customerSupportController.tickitIndex!].id!);
      customerSupportController.status = customerSupportController
          .ticketList[customerSupportController.tickitIndex!].ticketStatus!;
      customerSupportController.update();
      global.hideLoader();
    }
    print("App Is Release");
  }

  @override
  Future<bool> didPushRoute(String route) {
    print('HomeController - the route $route will be open');
    return super.didPushRoute(route);
  }

  // Optional
  @override
  Future<bool> didPopRoute() {
    print('HomeController - the current route will be closed');
    return super.didPopRoute();
  }

  // Optional
  @override
  void didChangeMetrics() {
    print('HomeController - the window size did change');
    super.didChangeMetrics();
  }

  // Optional
  @override
  void didChangePlatformBrightness() {
    print('HomeController - platform change ThemeMode');
    super.didChangePlatformBrightness();
  }

  @override
  void onHidden() {
  }
}
