// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';

import 'package:AstrowayCustomer/utils/date_converter.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/views/customer_support/customerSupportChatScreen.dart';
import 'package:AstrowayCustomer/views/placeOfBrithSearchScreen.dart';
import 'package:AstrowayCustomer/widget/customBottomButton.dart';
import 'package:AstrowayCustomer/widget/drodownWidget.dart';
import 'package:AstrowayCustomer/widget/textFieldLabelWidget.dart';
import 'package:AstrowayCustomer/widget/textFieldWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../controllers/astrologer_assistant_controller.dart';
import '../controllers/customer_support_controller.dart';
import '../controllers/reportController.dart';

class ReportInTakeForm extends StatelessWidget {
  final reportType;
  final String astrologerName;
  final int astrologerId;
  final int reportId;
  ReportInTakeForm({
    Key? key,
    this.reportType,
    required this.astrologerId,
    required this.astrologerName,
    required this.reportId,
  }) : super(key: key);
  ReportController reportController = Get.find<ReportController>();
  BottomNavigationController bottomNavigationController =
      Get.find<BottomNavigationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Set a distinct background color for the AppBar
        backgroundColor:
            Colors.blue, // Or any other color like Get.theme.primaryColor
        title: Text('Report intake Form',
                style: TextStyle(
                    color: Colors.black) // Set title text color for contrast
                )
            .tr(),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
              kIsWeb
                  ? Icons.arrow_back
                  : Platform.isIOS
                      ? Icons.arrow_back_ios
                      : Icons.arrow_back,
              color: Colors.black // Set back button color for contrast
              ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              bool isLogin = await global.isLogin();
              if (isLogin) {
                CustomerSupportController customerSupportController =
                    Get.find<CustomerSupportController>();
                AstrologerAssistantController astrologerAssistantController =
                    Get.find<AstrologerAssistantController>();
                global.showOnlyLoaderDialog(context);
                await customerSupportController.getCustomerTickets();
                await astrologerAssistantController
                    .getChatWithAstrologerAssisteant();
                global.hideLoader();
                Get.to(() => CustomerSupportChat());
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8, right: 30),
              child: Image.asset(
                Images.customerService,
                color: Colors
                    .black, // Set customer service icon color for contrast
                height: 25,
                width: 25,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GetBuilder<ReportController>(builder: (c) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                Text('Report Type:',
                        style: Get.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold))
                    .tr(),
                SizedBox(height: 15),
                Text('$reportType', style: Get.textTheme.titleMedium).tr(),
                SizedBox(height: 15),
                TextFieldWidget(
                  controller: reportController.fristNameController,
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ],
                  labelText: 'First Name',
                  focusNode: reportController.firstNamefocus,
                ),
                TextFieldWidget(
                  controller: reportController.lastNameController,
                  labelText: 'Last name',
                  focusNode: reportController.lastNamefocus,
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    child: Theme(
                      data: ThemeData(
                        dialogTheme: DialogTheme(
                          contentTextStyle:
                              const TextStyle(color: Colors.white),
                          backgroundColor: Colors.grey[800],
                          surfaceTintColor: Colors.grey[800],
                        ),
                      ),
                      child: InternationalPhoneNumberInput(
                        textFieldController: reportController.phoneController,
                        inputDecoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Phone number',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontFamily: "verdana_regular",
                              fontWeight: FontWeight.w400,
                            )),
                        onInputValidated: (bool value) {
                          // log('$value');
                        },
                        selectorConfig: const SelectorConfig(
                          leadingPadding: 2,
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: const TextStyle(color: Colors.black),
                        searchBoxDecoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2.w)),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            hintText: "Search",
                            hintStyle: const TextStyle(
                              color: Colors.black,
                            )),
                        initialValue: PhoneNumber(isoCode: 'IN'),
                        formatInput: false,
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: false),
                        inputBorder: InputBorder.none,
                        onSaved: (PhoneNumber number) {
                          reportController.updateCountryCode(number.dialCode);
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        onInputChanged: (PhoneNumber number) {},
                        onSubmit: () {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                  // SizedBox(
                  //     child: IntlPhoneField(
                  //   autovalidateMode: null,
                  //   showDropdownIcon: false,
                  //   onCountryChanged: (value) {
                  //     reportController.firstNamefocus.unfocus();
                  //     reportController.lastNamefocus.unfocus();
                  //     reportController.phonefocus.unfocus();
                  //     reportController.updateCountryCode(value.code);
                  //   },
                  //   controller: reportController.phoneController,
                  //   keyboardType: TextInputType.phone,
                  //   cursorColor: global.coursorColor,
                  //   focusNode: reportController.phonefocus,
                  //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  //   decoration: InputDecoration(
                  //       contentPadding: const EdgeInsets.symmetric(
                  //           vertical: 10, horizontal: 10),
                  //       hintText: 'Phone Number',
                  //       errorText: null,
                  //       hintStyle: TextStyle(
                  //         color: Colors.grey,
                  //         fontSize: 16,
                  //         fontFamily: "verdana_regular",
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //       counterText: ''),
                  //   initialCountryCode: reportController.countryCode ?? 'IN',
                  //   onChanged: (phone) {
                  //     print('length ${phone.number.length}');
                  //   },
                  // )),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFieldLabelWidget(
                        label: 'Gender',
                      ),
                      Flexible(
                        flex: 1,
                        child: RadioListTile(
                          title: Text("Male").tr(),
                          value: "male",
                          groupValue: reportController.gender,
                          dense: true,
                          activeColor: Get.theme.primaryColor,
                          contentPadding: EdgeInsets.all(0.0),
                          onChanged: (value) {
                            reportController.updateGeneder(value);
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: RadioListTile(
                          title: Text("Female").tr(),
                          value: "female",
                          groupValue: reportController.gender,
                          activeColor: Get.theme.primaryColor,
                          contentPadding: EdgeInsets.all(0.0),
                          dense: true,
                          onChanged: (value) {
                            reportController.updateGeneder(value);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 78,
                      )
                    ]),
                InkWell(
                  onTap: () async {
                    reportController.firstNamefocus.unfocus();
                    reportController.lastNamefocus.unfocus();
                    reportController.phonefocus.unfocus();
                    var datePicked = await DatePicker.showSimpleDatePicker(
                      context,
                      initialDate: DateTime(1994),
                      firstDate: DateTime(1960),
                      lastDate: DateTime.now(),
                      dateFormat: "dd-MM-yyyy",
                      itemTextStyle: Get.theme.textTheme.titleMedium!.copyWith(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                      titleText: 'Select Birth Date',
                      textColor: Get.theme.primaryColor,
                    );
                    if (datePicked != null) {
                      reportController.dobController.text =
                          DateConverter.isoStringToLocalDateOnly(
                              datePicked.toIso8601String());
                      reportController.selctedDate = datePicked;
                      reportController.update();
                    } else {}
                  },
                  child: IgnorePointer(
                    child: TextFieldWidget(
                      controller: reportController.dobController,
                      labelText: 'Date of Birth',
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    reportController.firstNamefocus.unfocus();
                    reportController.lastNamefocus.unfocus();
                    reportController.phonefocus.unfocus();
                    final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: 12, minute: 30),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData(
                              colorScheme: ColorScheme.light(
                                primary: Get.theme.primaryColor,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child ?? SizedBox(),
                          );
                        });
                    String formatTimeOfDay(TimeOfDay tod) {
                      final now = new DateTime.now();
                      final dt = DateTime(
                          now.year, now.month, now.day, tod.hour, tod.minute);
                      final format = DateFormat.jm(); //"6:00 AM"
                      return format.format(dt);
                    }

                    if (time != null) {
                      reportController.birthTimeController.text =
                          formatTimeOfDay(time);
                    } else {
                      reportController.birthTimeController.text =
                          formatTimeOfDay(TimeOfDay(hour: 12, minute: 30));
                    }
                  },
                  child: IgnorePointer(
                    child: TextFieldWidget(
                      controller: reportController.birthTimeController,
                      labelText: 'Time of Birth',
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    reportController.firstNamefocus.unfocus();
                    reportController.lastNamefocus.unfocus();
                    reportController.phonefocus.unfocus();
                    Get.to(() => PlaceOfBirthSearchScreen(
                          flagId: 7,
                        ));
                  },
                  child: IgnorePointer(
                    child: TextFieldWidget(
                      controller: reportController.placeController,
                      labelText: tr('Place of Birth'),
                    ),
                  ),
                ),
                TextFieldLabelWidget(
                  label: 'Marital Status',
                ),
                DropDownWidget(
                  item: [
                    'single',
                    'Married',
                    'Divorced',
                    'Separated',
                    'Widowed'
                  ],
                  hint: 'Select Marital Status',
                  callId: 1,
                ),
                TextFieldWidget(
                  controller: reportController.ocucupationController,
                  labelText: 'Occupation',
                  focusNode: reportController.occupationfocus,
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ],
                ),
                TextFieldLabelWidget(
                  label: 'I want answer in',
                ),
                DropDownWidget(
                  item: ['English', 'Hindi'],
                  hint: 'Select Answer Language',
                  callId: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: reportController.isEnterPartnerDetails,
                        activeColor: Get.theme.primaryColor,
                        onChanged: (bool? value) {
                          reportController.occupationfocus.unfocus();
                          reportController.partnerDetails(value!);
                        }),
                    Text("Enter Partner's Details",
                            style: Get.textTheme.titleMedium!.copyWith(
                                fontSize: 12,
                                decoration: TextDecoration.underline))
                        .tr()
                  ],
                ),
                if (reportController.isEnterPartnerDetails)
                  TextFieldWidget(
                    controller: reportController.partnerNameController,
                    labelText: "Partner's Name",
                    focusNode: reportController.partnerNamefocus,
                    inputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                    ],
                  ),
                if (reportController.isEnterPartnerDetails)
                  InkWell(
                    onTap: () async {
                      reportController.partnerNamefocus.unfocus();
                      var datePicked = await DatePicker.showSimpleDatePicker(
                        context,
                        initialDate: DateTime(1994),
                        firstDate: DateTime(1960),
                        lastDate: DateTime.now(),
                        dateFormat: "dd-MM-yyyy",
                        itemTextStyle:
                            Get.theme.textTheme.titleMedium!.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                        titleText: "Partner's Date of Birth",
                      );
                      if (datePicked != null) {
                        reportController.partnerDobController.text =
                            DateConverter.isoStringToLocalDateOnly(
                                datePicked.toIso8601String());
                        reportController.selctedPartnerDate = datePicked;
                        reportController.update();
                      }
                    },
                    child: IgnorePointer(
                      child: TextFieldWidget(
                        controller: reportController.partnerDobController,
                        labelText: "Partner's Date of Birth",
                      ),
                    ),
                  ),
                if (reportController.isEnterPartnerDetails)
                  InkWell(
                    onTap: () async {
                      reportController.partnerNamefocus.unfocus();
                      final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(hour: 12, minute: 30));
                      String formatTimeOfDay(TimeOfDay tod) {
                        final now = new DateTime.now();
                        final dt = DateTime(
                            now.year, now.month, now.day, tod.hour, tod.minute);
                        final format = DateFormat.jm(); //"6:00 AM"
                        return format.format(dt);
                      }

                      if (time != null) {
                        reportController.partnerBirthController.text =
                            formatTimeOfDay(time);
                      }
                    },
                    child: IgnorePointer(
                      child: TextFieldWidget(
                        controller: reportController.partnerBirthController,
                        labelText: "Partner's Time of Birth",
                      ),
                    ),
                  ),
                if (reportController.isEnterPartnerDetails)
                  InkWell(
                    onTap: () {
                      reportController.partnerNamefocus.unfocus();
                      Get.to(() => PlaceOfBirthSearchScreen(
                            flagId: 8,
                          ));
                    },
                    child: IgnorePointer(
                      child: TextFieldWidget(
                        controller: reportController.partnerPlaceController,
                        labelText: "Partner's Place of Birth",
                      ),
                    ),
                  ),
                TextFieldLabelWidget(
                  label: 'Any Comments*',
                ),
                TextField(
                  controller: reportController.commentController,
                  keyboardType: TextInputType.multiline,
                  minLines: 8,
                  maxLines: 8,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '1/400',
                      style: Get.textTheme.titleMedium!.copyWith(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
              ],
            );
          }),
        ),
      ),
      bottomSheet: GetBuilder<ReportController>(builder: (reportController) {
        return CustomBottomButton(
          onTap: () async {
            bool isvalid = reportController.isValidData();
            print(isvalid);
            if (!isvalid) {
              global.showToast(
                message: reportController.errorText,
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            } else {
              Get.dialog(
                AlertDialog(
                  backgroundColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  titlePadding: const EdgeInsets.all(8),
                  title: Column(
                    children: [
                      Text(
                        "Are you sure you want to get report?",
                        style: Get.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ).tr(),
                      const Divider()
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date of Birth',
                              style: Get.textTheme.bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold))
                          .tr(),
                      Text(
                        reportController.dobController.text,
                        style: TextStyle(fontSize: 12),
                      ),
                      Text('Time of Birth',
                              style: Get.textTheme.bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold))
                          .tr(),
                      Text(
                        reportController.birthTimeController.text,
                        style: TextStyle(fontSize: 12),
                      ),
                      Text('Place of Birth',
                              style: Get.textTheme.bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold))
                          .tr(),
                      Text(
                        reportController.placeController.text,
                        style: TextStyle(fontSize: 12),
                      ).tr(),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('Cancel',
                                      style: TextStyle(color: Colors.white))
                                  .tr(),
                              style: ButtonStyle(
                                maximumSize:
                                    WidgetStateProperty.all(Size(80, 40)),
                                backgroundColor: WidgetStateProperty.all(
                                    Get.theme.primaryColor),
                                foregroundColor:
                                    WidgetStateProperty.all(Colors.black),
                              ),
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
                                await reportController.addGetReportFormData(
                                    astrologerId, reportId);
                                global.hideLoader();
                                Get.back();
                              },
                              child: Text(
                                'Confirm',
                                style: TextStyle(color: Colors.white),
                              ).tr(),
                              style: ButtonStyle(
                                maximumSize:
                                    WidgetStateProperty.all(Size(80, 40)),
                                backgroundColor: WidgetStateProperty.all(
                                    Get.theme.primaryColor),
                                foregroundColor:
                                    WidgetStateProperty.all(Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          title: 'Ask $astrologerName',
        );
      }),
    );
  }
}
