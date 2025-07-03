import 'dart:io';

import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/controllers/reviewController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import '../../utils/images.dart';

// ignore: must_be_immutable
class KundliDetailsScreen extends StatefulWidget {
  KundliDetailsScreen() : super();

  @override
  State<KundliDetailsScreen> createState() => _KundliDetailsScreenState();
}

class _KundliDetailsScreenState extends State<KundliDetailsScreen> {
  final KundliController kundliController = Get.find<KundliController>();

  final ReviewController reviewController = Get.find<ReviewController>();

  SplashController splashController = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
        Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
        title: Text(
          'Kundli',
          style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
              fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white),
        ).tr(),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
              kIsWeb
                  ? Icons.arrow_back
                  : Platform.isIOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
              color: Colors.white //Get.theme.iconTheme.color,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              global.showOnlyLoaderDialog(context);
              await kundliController.shareKundli(kundliController
                  .pdfKundaliData!.recordList!.response
                  .toString());
              global.hideLoader();
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      Images.whatsapp,
                      height: 40,
                      width: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Share',
                          style: Get.textTheme.titleMedium!
                              .copyWith(fontSize: 12, color: Colors.white))
                          .tr(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: kundliController.pdfKundaliData == null
          ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text("Please Wait Kundali is Loading...")
            ],
          ))
          : Container(
        child: SfPdfViewer.network(
          "${kundliController.pdfKundaliData!.recordList!.response}",
          onDocumentLoadFailed: (e) {
            Fluttertoast.showToast(msg: "PDF Failed to Load");
            Get.back();
          },
          onDocumentLoaded: (e) {},
        ),
      ),

    );
  }
}