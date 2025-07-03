// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../widget/commonAppbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CommonAppBar(
            title: 'Privacy Policy',
          )),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: WebUri('https://jyotishionline.com/astro/privacyPolicy')),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          transparentBackground: true,
        ),
        onProgressChanged: (controller, progress) {
          // Note: You can update your loading bar widget here.
          // return CircularProgressIndicator();
        },
        onReceivedError: (controller, request, error) {
          debugPrint('Terms condition error: $error');
        },
        onLoadStop: (controller, url) {
          // Handle loading stop
        },
        onWebViewCreated: (controller) {
          // Here you can access the InAppWebViewController instance
        },
        onConsoleMessage: (controller, consoleMessage) {
          // Handle console messages
          debugPrint('console web $consoleMessage');
        },
      ),
      //    body:
      //  WebViewWidget(controller: controller),
    );
  }
}
