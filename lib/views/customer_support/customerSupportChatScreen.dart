// ignore_for_file: deprecated_member_use

import 'package:AstrowayCustomer/views/customer_support/chatWithAstrologerAssistant.dart';
import 'package:AstrowayCustomer/views/customer_support/chatWithCustomerSupport.dart';
import 'package:AstrowayCustomer/widget/commonAppbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../controllers/bottomNavigationController.dart';
import '../bottomNavigationBarScreen.dart';

class CustomerSupportChat extends StatelessWidget {
  const CustomerSupportChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () async {
          BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();
          bottomNavigationController.setIndex(0, 0);
          Get.to(() => BottomNavigationBarScreen(
                index: 0,
              ));
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: CommonAppBar(
                title: 'Support Chat',
                flagId: 1,
              )),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(indicatorColor: Get.theme.primaryColor, tabs: [
                Container(height: 35, alignment: Alignment.center, child: Text('Customer Support').tr()),
                Container(height: 35, alignment: Alignment.center, child: Text('Astrologer Assistant').tr()),
              ]),
              Expanded(
                child: TabBarView(children: [
                  ChatWithCustomerSupport(),
                  ChatWithAstrologerAssistant(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
