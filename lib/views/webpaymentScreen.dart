// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../utils/global.dart';
import '../widget/commonAppbar.dart';
import 'bottomNavigationBarScreen.dart';

import '../utils/global.dart' as global;

class PaymentScreen extends StatefulWidget {
  String url;
  PaymentScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late InAppWebViewController _controller;
  final historyController = Get.find<HistoryController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: CommonAppBar(
          title: 'Payment Information',
        ),
      ),
      body: Container(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
              cacheEnabled: true,
              useShouldInterceptRequest: true
          ),
          onReceivedError: (controller, request, error) {
            log('error: ${error.toString()}');
          },
          onLoadResource: (controller, resource) {
            log('onLoadResource : ${resource}');
          },
          onLoadStart: (controller, url) {
            log('start url: ${url.toString()}');
          },
          onReceivedHttpError: (controller, request, error) {
            log('http error: ${error.toString()} and req is $request');
          },
          onLoadStop: (controller, url)async {
            log('onLoadStop called: ${url.toString()}');
            // log('check: ${imgBaseurl}payment-success');

            if (url
                .toString()
                .startsWith("${imgBaseurl}payment-success")) {
              await global.splashController.getCurrentUserData();
              await historyController.getChatHistory(
                  global.currentUserId!, false);
              Get.off(() => BottomNavigationBarScreen(index: 0));
              Fluttertoast.showToast(
                msg: "Payment Success!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Get.theme.primaryColor,
                textColor: Colors.white,
                fontSize: 14.0,
              );
            } else if (url
                .toString()
                .startsWith("${imgBaseurl}payment-failed")) {
              Get.off(() => BottomNavigationBarScreen(index: 0));
              Fluttertoast.showToast(
                msg: "Payment Failed!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Get.theme.primaryColor,
                textColor: Colors.white,
                fontSize: 14.0,
              );
            }
          },
          onWebViewCreated: (webviewcontroller) {
            _controller = webviewcontroller;

            log('onWebViewCreated: }');

            kIsWeb
                ? {}
                : _controller.addJavaScriptHandler(
                    handlerName: 'PaymentSuccess',
                    callback: (args) {
                      log('loaded PaymentSuccess: ${args.toString()}');

                      Get.off(() => BottomNavigationBarScreen(index: 0));
                      Fluttertoast.showToast(
                        msg: "Payment Success!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Get.theme.primaryColor,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                    },
                  );
            kIsWeb
                ? {}
                : _controller.addJavaScriptHandler(
                    handlerName: 'PaymentFailed',
                    callback: (args) {
                      log('loaded PaymentFailed: ${args.toString()}');

                      Get.off(() => BottomNavigationBarScreen(index: 0));
                      Fluttertoast.showToast(
                        msg: "Payment Failed!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Get.theme.primaryColor,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                    },
                  );
          },
        ),
      ),
    );
  }


}
