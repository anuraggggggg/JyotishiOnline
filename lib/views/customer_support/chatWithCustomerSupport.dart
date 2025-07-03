import 'package:AstrowayCustomer/controllers/customer_support_controller.dart';
import 'package:AstrowayCustomer/utils/date_converter.dart';
import 'package:AstrowayCustomer/views/customer_support/customer_support_chat_screen.dart';
import 'package:AstrowayCustomer/views/customer_support/helpAndSupportScreen.dart';
import 'package:AstrowayCustomer/widget/customBottomButton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:AstrowayCustomer/utils/global.dart' as global;

class ChatWithCustomerSupport extends StatelessWidget {
  const ChatWithCustomerSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: Get.height,
        decoration: BoxDecoration(color: Color.fromARGB(255, 240, 233, 233)),
        child: GetBuilder<CustomerSupportController>(builder: (customerSupportController) {
          return customerSupportController.ticketList.isEmpty
              ? Center(
                  child: Text('No ticket available').tr(),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Expanded(
                      child: ListView.builder(
                          itemCount: customerSupportController.ticketList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                print('firebase chatd :- ${customerSupportController.ticketList[index].chatId}');
                                if (customerSupportController.ticketList[index].chatId != "") {
                                  global.showOnlyLoaderDialog(context);
                                  customerSupportController.reviewController.clear();
                                  customerSupportController.rating = 0;
                                  customerSupportController.reviewId = null;
                                  await customerSupportController.getCustomerReview(customerSupportController.ticketList[index].id!);
                                  customerSupportController.status = customerSupportController.ticketList[index].ticketStatus!;
                                  customerSupportController.isIn = true;
                                  customerSupportController.tickitIndex = index;
                                  customerSupportController.update();
                                  global.hideLoader();
                                  Get.to(() => CustomerSupportChatScreen(
                                        flagId: 1,
                                        ticketNo: customerSupportController.ticketList[index].ticketNumber!,
                                        fireBasechatId: customerSupportController.ticketList[index].chatId!,
                                        ticketId: customerSupportController.ticketList[index].id!,
                                        ticketStatus: customerSupportController.ticketList[index].ticketStatus!,
                                      ));
                                }
                              },
                              onLongPress: () {
                                print('long pressed');
                                Get.dialog(AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text(
                                    "Are you sure you want delete ticket?",
                                    style: Get.textTheme.titleMedium,
                                  ).tr(),
                                  content: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: Text('No').tr(),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            global.showOnlyLoaderDialog(context);
                                            await customerSupportController.deleteOneTicket(
                                              customerSupportController.ticketList[index].id!,
                                            );
                                            global.hideLoader();
                                            Get.back();
                                          },
                                          child: Text('Yes').tr(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                              },
                              child: Container(
                                  margin: const EdgeInsets.all(6),
                                  width: Get.width,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${customerSupportController.ticketList[index].name}".toUpperCase(),
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              customerSupportController.ticketList[index].ticketStatus!.toUpperCase() == "PAUSE"
                                                  ? ElevatedButton(
                                                      onPressed: () async {
                                                        global.showOnlyLoaderDialog(context);
                                                        await customerSupportController.restartSupportChat(customerSupportController.ticketList[index].id!);
                                                        global.hideLoader();
                                                      },
                                                      child: Text('Restart Chat').tr())
                                                  : Text(
                                                      "${customerSupportController.ticketList[index].ticketStatus ?? 'waiting'}".toUpperCase(),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: customerSupportController.ticketList[index].ticketStatus!.toUpperCase() == "WAITING"
                                                            ? Colors.blue
                                                            : customerSupportController.ticketList[index].ticketStatus!.toUpperCase() == "OPEN"
                                                                ? Colors.green
                                                                : Colors.red,
                                                      ),
                                                    )
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Ticket No:${customerSupportController.ticketList[index].ticketNumber}').tr(),
                                              Text('${customerSupportController.ticketList[index].description}'),
                                              Text(DateConverter.dateTimeStringToDateTime(customerSupportController.ticketList[index].createdAt!.toString())),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                );
        }),
      ),
      bottomSheet: GetBuilder<CustomerSupportController>(builder: (customerSupportController) {
        return CustomBottomButton(
          title: 'Chat With Customer Support',
          onTap: () async {
            global.showOnlyLoaderDialog(context);
            await customerSupportController.getClosedTicketStatus();
            if (!customerSupportController.isOpenTicket) {
              await customerSupportController.getHelpAndSupport();
              global.hideLoader();
              Get.to(() => HeplAndSupportScreen());
            } else {
              global.hideLoader();
              Get.dialog(
                AlertDialog(
                  backgroundColor: Colors.white,
                  contentPadding: const EdgeInsets.all(0),
                  titlePadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  title: Text(
                    "You already have an open ticket",
                    style: Get.textTheme.titleMedium,
                  ).tr(),
                  content: TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('Ok', style: TextStyle(color: Get.theme.primaryColor)).tr(),
                  ),
                ),
              );
            }
          },
        );
      }),
    );
  }
}
