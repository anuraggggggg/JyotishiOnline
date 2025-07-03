import 'dart:io';

import 'package:AstrowayCustomer/controllers/history_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

// ignore: must_be_immutable
class ViewReportScreen extends StatelessWidget {
  int? index;
  ViewReportScreen({Key? key, this.index}) : super(key: key);
  HistoryController historyController = Get.find<HistoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
           kIsWeb? Icons.arrow_back:     Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.white//Get.theme.iconTheme.color,
          ),
        ),
        backgroundColor: Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
        title: Text('View Report',style: TextStyle(color: Colors.white),).tr(),
      ),
      body: SfPdfViewer.network('${global.imgBaseurl}${historyController.reportHistoryList[index!].reportFile}', enableDocumentLinkAnnotation: false),
    );
  }
}
