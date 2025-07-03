import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:AstrowayCustomer/controllers/walletController.dart';
import 'package:AstrowayCustomer/views/placeOfBrithSearchScreen.dart';
import 'package:AstrowayCustomer/widget/drodownWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:responsive_sizer/responsive_sizer.dart';

class KundliBornPlaceWidget extends StatefulWidget {
  final KundliController kundliController;
  // final VoidCallback? onPressed;
  const KundliBornPlaceWidget({
    Key? key,
    required this.kundliController,
  }) : super(key: key);

  @override
  State<KundliBornPlaceWidget> createState() => _KundliBornPlaceWidgetState();
}

class _KundliBornPlaceWidgetState extends State<KundliBornPlaceWidget> {
  String type = "medium";
  

  WalletController walletController = Get.find<WalletController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: () {
              Get.to(() => PlaceOfBirthSearchScreen());
            },
            child: IgnorePointer(
              child: TextField(
                controller: widget.kundliController.birthKundliPlaceController,
                onChanged: (_) {},
                decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintText: 'Birth Place',
                    hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          height: 25,
        ),
        Flexible(
          flex: 1,
          child: RadioListTile(
            title: widget.kundliController.pdfPriceData!.isFreeSession == true
                ? Text("Free Kundali").tr()
                : Text("Basic Kundali (₹${widget.kundliController.pdfPriceData!.recordList!.small})")
                    .tr(),
            value: "small",
            groupValue: type,
            dense: true,
            activeColor: Get.theme.primaryColor,
            contentPadding: EdgeInsets.all(0.0),
            onChanged: (value) {
              setState(() {
                type = value!;
              });
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: RadioListTile(
            title: Text(
                    "Detailed Kundali (₹${widget.kundliController.pdfPriceData!.recordList!.medium})")
                .tr(),
            value: "medium",
            groupValue: type,
            dense: true,
            activeColor: Get.theme.primaryColor,
            contentPadding: EdgeInsets.all(0.0),
            onChanged: (value) {
              setState(() {
                type = value!;
              });
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: RadioListTile(
            title: Text(
                    "Full-fledged Kundali (₹${widget.kundliController.pdfPriceData!.recordList!.large})")
                .tr(),
            value: "large",
            groupValue: type,
            dense: true,
            activeColor: Get.theme.primaryColor,
            contentPadding: EdgeInsets.all(0.0),
            onChanged: (value) {
              setState(() {
                type = value!;
              });
            },
          ),
        ),
        SizedBox(height: 10,),
        Text("Select Your Kundali Language",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 18.sp
        ),),
        SizedBox(height: 10,),
        DropDownWidget(
          item: [
            'English',
            'Tamil',
            'Kannada',
            'Telugu',
            'Hindi',
            'Malayalam',
            'Spanish',
            'French',
          ],
          hint: tr('Select Your Language',),
          callId: 4,
        ),
        SizedBox(height: 15,),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.all(0)),
              backgroundColor:
                  WidgetStateProperty.all(Get.theme.primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey)),
              ),
            ),


            onPressed: () async {
              if (type == "small"
                  ? (widget.kundliController.pdfPriceData!.isFreeSession == true
                      ? false
                      : global.splashController.currentUser!.walletAmount! <
                          int.parse(widget
                              .kundliController.pdfPriceData!.recordList!.small
                              .toString()))
                  : type == "medium"
                      ? (global.splashController.currentUser!.walletAmount! <
                          int.parse(widget
                              .kundliController.pdfPriceData!.recordList!.medium
                              .toString()))
                      : type == "large"
                          ? (global
                                  .splashController.currentUser!.walletAmount! <
                              int.parse(widget.kundliController.pdfPriceData!
                                  .recordList!.large
                                  .toString()))
                          : false) {
                openBottomSheetRechrage(context, type == "small"?widget
                    .kundliController.pdfPriceData!.recordList!.small
                    .toString():(type == "medium"?"${widget.kundliController.pdfPriceData!.recordList!.medium.toString()}":
                widget.kundliController.pdfPriceData!
                    .recordList!.large
                    .toString()));
              } else {
                if (widget.kundliController.birthKundliPlaceController.text ==
                    "") {
                  global.showToast(
                    message: 'Please select birth place',
                    textColor: global.textColor,
                    bgColor: global.toastBackGoundColor,
                  );
                } else {
                  widget.kundliController
                      .updateIcon(widget.kundliController.initialIndex);
                  global.showOnlyLoaderDialog(context);
                  await widget.kundliController.addKundliData(type,
                      type.toString()=="large"?
                      int.parse(widget.kundliController.pdfPriceData!
                          .recordList!.large
                          .toString()):(type.toString()=="medium"?int.parse(widget
                          .kundliController.pdfPriceData!.recordList!.medium
                          .toString()):(
                          type.toString()=="small"?(widget.kundliController.pdfPriceData!.isFreeSession == true?
                          0:int.parse(widget
                          .kundliController.pdfPriceData!.recordList!.small
                          .toString())):0
                      )
                      )
                  );
                  await widget.kundliController.getKundliList();
                  widget.kundliController.initialIndex = 0;
                  global.hideLoader();
                  Get.back();
                }
              }
            },
            child: Text(
              'Submit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white
              ),
            ).tr(),
          ),
        ),

      ],
    );
  }

  void openBottomSheetRechrage(
    BuildContext context,
    String minBalance,
  ) {
    Get.bottomSheet(
      Container(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.85,
                                    child: minBalance != ''
                                        ? Text('Minimum balance (${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance) is required to Create Kundali',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red))
                                            .tr()
                                        : const SizedBox(),
                                  ),
                                  GestureDetector(
                                    child: Padding(
                                      padding: minBalance == ''
                                          ? const EdgeInsets.only(top: 8)
                                          : const EdgeInsets.only(top: 0),
                                      child: Icon(Icons.close, size: 18),
                                    ),
                                    onTap: () {
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, bottom: 5),
                                child: Text('Recharge Now',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500))
                                    .tr(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Icon(Icons.lightbulb_rounded,
                                        color: Get.theme.primaryColor,
                                        size: 13),
                                  ),
                                  Expanded(
                                      child: Text(
                                              'Minimum balance required ${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance',
                                              style: TextStyle(fontSize: 12))
                                          .tr())
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 3.8 / 2.3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8),
                    shrinkWrap: true,
                    itemCount: walletController.rechrage.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Get.delete<RazorPayController>();
                          // Get.to(() => PaymentInformationScreen(
                          //     flag: 0,
                          //     amount: double.parse(
                          //         walletController.payment[index])));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                                child: Text(
                              '${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${walletController.rechrage[index]}',
                              style: TextStyle(fontSize: 13),
                            )),
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.8),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }
}
