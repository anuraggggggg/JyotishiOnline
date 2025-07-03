// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/callController.dart';
import 'package:AstrowayCustomer/controllers/IntakeController.dart';
import 'package:AstrowayCustomer/controllers/chatController.dart';

import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/utils/services/location_service.dart';
import 'package:AstrowayCustomer/views/CustomText.dart';
import 'package:AstrowayCustomer/views/paymentInformationScreen.dart';
import 'package:AstrowayCustomer/views/placeOfBrithSearchScreen.dart';
import 'package:AstrowayCustomer/widget/customBottomButton.dart';
import 'package:AstrowayCustomer/widget/textFieldLabelWidget.dart';
import 'package:AstrowayCustomer/widget/textFieldWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../controllers/dropDownController.dart';
import '../controllers/walletController.dart';
import '../utils/date_converter.dart';
import '../widget/drodownWidget.dart';

class CallIntakeFormScreen extends StatefulWidget {
  final reportType;
  final String astrologerName;
  final int astrologerId;
  final String type;
  final String astrologerProfile;
  final bool? isFreeAvailable;
  final String? rate;

  CallIntakeFormScreen(
      {Key? key,
      this.reportType,
      this.isFreeAvailable = false,
      required this.astrologerName,
      required this.astrologerId,
      required this.type,
      required this.rate,
      required this.astrologerProfile})
      : super(key: key);

  @override
  State<CallIntakeFormScreen> createState() => _CallIntakeFormScreenState();
}

class _CallIntakeFormScreenState extends State<CallIntakeFormScreen> {
  SplashController splashController = Get.find<SplashController>();

  BottomNavigationController bottomNavigationController =
      Get.find<BottomNavigationController>();

  IntakeController callIntakeController = Get.find<IntakeController>();
  WalletController walletController = Get.find<WalletController>();

  CallController callController = Get.find<CallController>();

  ChatController chatController = Get.find<ChatController>();

  List time = [5, 10, 15, 20, 25, 30];
  int selectTime = 0;
  bool isChecked = false;
  double? _latitude;
  double? _longitude;

  Timer? _debounce;
  List<LocationSuggestion> _suggestions = [];

  //final _initalValue=PhoneNumber(isoCode: 'IN');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:
            Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
        title: Text(
          '${widget.type} ${tr("Intake Form")}',
          style: Get.theme.primaryTextTheme.titleLarge!.copyWith(
              fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
        ).tr(),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
              kIsWeb
                  ? Icons.arrow_back
                  : Platform.isIOS
                      ? Icons.arrow_back_ios
                      : Icons.arrow_back,
              color: Colors.black //Get.theme.iconTheme.color,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GetBuilder<IntakeController>(builder: (c) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                TextFieldWidget(
                  controller: callIntakeController.nameController,
                  focusNode: callIntakeController.namefocus,
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ],
                  labelText: 'Name',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                            textFieldController:
                                callIntakeController.phoneController,
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
                            selectorTextStyle:
                                const TextStyle(color: Colors.black),
                            searchBoxDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2.w)),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
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
                              callIntakeController
                                  .updateCountryCode(number.dialCode);
                            },
                            onFieldSubmitted: (value) {
                              log('On onFieldSubmitted: $value');
                              FocusScope.of(context).unfocus();
                            },
                            onInputChanged: (PhoneNumber number) {},
                            onSubmit: () {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        // SizedBox(
                        //     child: IntlPhoneField(
                        //   pickerDialogStyle:
                        //       PickerDialogStyle(backgroundColor: Colors.white),
                        //   autovalidateMode: null,
                        //   showDropdownIcon: false,
                        //   onCountryChanged: (value) {
                        //     callIntakeController.namefocus.unfocus();
                        //     callIntakeController.phonefocus.unfocus();
                        //     callIntakeController.updateCountryCode(value.code);
                        //   },
                        //   focusNode: callIntakeController.phonefocus,
                        //   controller: callIntakeController.phoneController,
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly
                        //   ],
                        //   keyboardType: TextInputType.phone,
                        //   cursorColor: global.coursorColor,
                        //   decoration: InputDecoration(
                        //     contentPadding: const EdgeInsets.symmetric(
                        //         vertical: 10, horizontal: 10),
                        //     hintText: tr("Phone number"),
                        //     errorText: null,
                        //     counterText: '',
                        //   ),
                        //   initialCountryCode:
                        //       callIntakeController.countryCode ?? 'IN',
                        //   onChanged: (phone) {
                        //     print('length ${phone.number}');
                        //
                        //     callIntakeController.checkContact(phone.number);
                        //   },
                        // )),
                      ),
                    ),
                    // !callIntakeController.isVarified
                    //     ? GetBuilder<IntakeController>(builder: (c) {
                    //         return Padding(
                    //           padding: const EdgeInsets.all(8.0),
                    //           child: SizedBox(
                    //             height: 30,
                    //             child: TextButton(
                    //               style: ButtonStyle(
                    //                 padding: WidgetStateProperty.all(
                    //                     EdgeInsets.all(4)),
                    //                 fixedSize: WidgetStateProperty.all(
                    //                     Size.fromWidth(90)),
                    //                 backgroundColor: WidgetStateProperty.all(
                    //                     Get.theme.primaryColor),
                    //                 shape: WidgetStateProperty.all(
                    //                   RoundedRectangleBorder(
                    //                     borderRadius: BorderRadius.circular(10),
                    //                     side: BorderSide(
                    //                       color: Color.fromARGB(
                    //                           255, 189, 189, 189),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //               onPressed: () async {
                    //                 if (callIntakeController
                    //                         .intakeContact!.length ==
                    //                     10) {
                    //                   global.showOnlyLoaderDialog(context);
                    //                   await callIntakeController.verifyOTP();
                    //                 }
                    //               },
                    //               child: Text(
                    //                 'Verify',
                    //                 style:
                    //                     Get.theme.primaryTextTheme.titleSmall,
                    //                 textAlign: TextAlign.center,
                    //               ).tr(),
                    //             ),
                    //           ),
                    //         );
                    //       })
                    //     : const SizedBox(),
                  ],
                ),
                SizedBox(height: 10),
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
                          groupValue: callIntakeController.gender,
                          dense: true,
                          activeColor: Get.theme.primaryColor,
                          contentPadding: EdgeInsets.all(0.0),
                          onChanged: (value) {
                            callIntakeController.updateGeneder(value);
                          },
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: RadioListTile(
                          title: Text("Female").tr(),
                          value: "female",
                          groupValue: callIntakeController.gender,
                          activeColor: Get.theme.primaryColor,
                          contentPadding: EdgeInsets.all(0.0),
                          dense: true,
                          onChanged: (value) {
                            callIntakeController.updateGeneder(value);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 78,
                      )
                    ]),
                InkWell(
                  onTap: () async {
                    callIntakeController.namefocus.unfocus();
                    callIntakeController.phonefocus.unfocus();
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
                      titleText: tr('Select Birth Date'),
                      textColor: Get.theme.primaryColor,
                    );
                    if (datePicked != null) {
                      callIntakeController.dobController.text =
                          DateConverter.isoStringToLocalDateOnly(
                              datePicked.toIso8601String());
                      callIntakeController.selctedDate = datePicked;
                      callIntakeController.update();
                    } else {
                      callIntakeController.dobController.text =
                          DateConverter.isoStringToLocalDateOnly(
                              DateTime(1994).toIso8601String());
                      callIntakeController.selctedDate = DateTime(1994);
                      callIntakeController.update();
                    }
                  },
                  child: IgnorePointer(
                    child: TextFieldWidget(
                      controller: callIntakeController.dobController,
                      labelText: tr('Date of Birth'),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    callIntakeController.namefocus.unfocus();
                    callIntakeController.phonefocus.unfocus();
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
                      callIntakeController.birthTimeController.text =
                          formatTimeOfDay(time);
                    }
                  },
                  child: Column(
                    children: [
                      IgnorePointer(
                        child: TextFieldWidget(
                          controller: callIntakeController.birthTimeController,
                          labelText: tr('Time of Birth'),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            // fillColor: MaterialStateProperty.resolveWith(getColor),
                            value: isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                          ),
                          CustomText(text: "Don't know ")
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),

                StatefulBuilder(
                  builder: (context, setStateSB) {
                    return Column(
                      children: [
                        TextFormField(
                          controller: callIntakeController.placeController,
                          onChanged: (value) {
                            if (_debounce?.isActive ?? false) {
                              _debounce!.cancel();
                            }

                            _debounce = Timer(const Duration(milliseconds: 500),
                                () async {
                              if (value.isEmpty) {
                                setStateSB(() => _suggestions = []);
                                _latitude =
                                    null; // Clear lat/lon if text is cleared
                                _longitude = null;
                                return;
                              }

                              try {
                                final result =
                                    await LocationService.fetchCitySuggestions(
                                        value);
                                setStateSB(() => _suggestions = result);
                              } catch (e) {
                                print('Error fetching suggestions: $e');
                                setStateSB(() => _suggestions = []);
                                // Optionally show a temporary message to the user here
                              }
                            });
                          },
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Location is required'
                              : null,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Birth Place',
                            hintText: 'e.g., Mumbai, India',
                            labelStyle:
                                const TextStyle(fontWeight: FontWeight.w500),
                            hintStyle: TextStyle(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: 1),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(),
                            ),
                            errorBorder: OutlineInputBorder(
                              // Added error borders for consistency
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.redAccent, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              // Added focused error borders
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                        ),
                        // Display suggestions only if there are any
                        if (_suggestions.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            margin: const EdgeInsets.only(top: 8),
                            // Constrain height for the suggestion list
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.3),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _suggestions.length,
                              itemBuilder: (context, index) {
                                final item = _suggestions[index];
                                return ListTile(
                                  title: Text(
                                    item.displayName,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  onTap: () {
                                    callIntakeController.placeController.text =
                                        item.displayName;
                                    _latitude = double.tryParse(item.lat);
                                    _longitude = double.tryParse(item.lon);
                                    setStateSB(() => _suggestions
                                        .clear()); // Clear suggestions
                                    FocusScope.of(context)
                                        .unfocus(); // Unfocus text field
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),

                // InkWell(
                //   onTap: () {
                //     callIntakeController.namefocus.unfocus();
                //     callIntakeController.phonefocus.unfocus();
                //     Get.to(() => PlaceOfBirthSearchScreen(
                //           flagId: 5,
                //         ));
                //   },
                //   child: IgnorePointer(
                //     child: TextFieldWidget(
                //       controller: callIntakeController.placeController,
                //       labelText: tr('Place of Birth'),
                //     ),
                //   ),
                // ),
                TextFieldLabelWidget(
                  label: 'Marital Status (Optional)',
                ),
                DropDownWidget(
                  item: [
                    'single',
                    'Married',
                    'Divorced',
                    'Separated',
                    'Widowed'
                  ],
                  hint: tr('Select Marital Status'),
                  callId: 1,
                ),
                const SizedBox(
                  height: 6,
                ),
                TextFieldWidget(
                  controller: callIntakeController.ocupationController,
                  focusNode: callIntakeController.occupationfocus,
                  labelText: 'Occupation (Optional)',
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ],
                ),
                SizedBox(
                  height: 6,
                ),
                widget.isFreeAvailable == true
                    ? SizedBox()
                    : Text("How Many Minutes you want to talk?"),
                widget.isFreeAvailable == true
                    ? SizedBox()
                    : SizedBox(
                        height: 10,
                      ),
                widget.isFreeAvailable == true
                    ? SizedBox()
                    : Container(
                        height: 25,
                        // color: Colors.redAccent,
                        child: ListView.builder(
                            itemCount: time.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectTime = index;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                      color: selectTime == index
                                          ? Colors.black
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  child: Text(
                                    "${time[index]} Mins",
                                    style: TextStyle(
                                        color: selectTime == index
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              );
                            }),
                      ),
                TextFieldLabelWidget(
                  label: 'Topic of Concern',
                ),
                DropDownWidget(
                  item: ['Study', 'Future', 'Past'],
                  hint: tr('Select Topic of Concern'),
                  callId: 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: callIntakeController.isEnterPartnerDetails,
                        activeColor: Get.theme.primaryColor,
                        onChanged: (bool? value) {
                          callIntakeController.partnerDetails(value!);
                        }),
                    Text("Enter Partner's Details",
                        style: Get.textTheme.titleMedium!.copyWith(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        )).tr()
                  ],
                ),
                if (callIntakeController.isEnterPartnerDetails)
                  if (callIntakeController.isEnterPartnerDetails)
                    TextFieldWidget(
                      controller: callIntakeController.partnerNameController,
                      labelText: "Partner's Name",
                      focusNode: callIntakeController.partnerNamefocus,
                      inputFormatter: [
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                      ],
                    ),
                if (callIntakeController.isEnterPartnerDetails)
                  if (callIntakeController.isEnterPartnerDetails)
                    InkWell(
                      onTap: () async {
                        callIntakeController.occupationfocus.unfocus();
                        callIntakeController.partnerNamefocus.unfocus();
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
                          titleText: tr("Select Partner's Birth Date"),
                        );
                        if (datePicked != null) {
                          callIntakeController.partnerDobController.text =
                              DateConverter.isoStringToLocalDateOnly(
                                  datePicked.toIso8601String());
                          callIntakeController.selctedPartnerDate = datePicked;
                          callIntakeController.update();
                        } else {
                          callIntakeController.partnerDobController.text =
                              DateConverter.isoStringToLocalDateOnly(
                                  DateTime(1994).toIso8601String());
                          callIntakeController.selctedPartnerDate =
                              DateTime(1994);
                          callIntakeController.update();
                        }
                      },
                      child: IgnorePointer(
                        child: TextFieldWidget(
                          controller: callIntakeController.partnerDobController,
                          labelText: "Partner's DOB",
                        ),
                      ),
                    ),
                if (callIntakeController.isEnterPartnerDetails)
                  if (callIntakeController.isEnterPartnerDetails)
                    InkWell(
                      onTap: () async {
                        callIntakeController.occupationfocus.unfocus();
                        callIntakeController.partnerNamefocus.unfocus();

                        final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(hour: 12, minute: 30));
                        String formatTimeOfDay(TimeOfDay tod) {
                          final now = new DateTime.now();
                          final dt = DateTime(now.year, now.month, now.day,
                              tod.hour, tod.minute);
                          final format = DateFormat.jm(); //"6:00 AM"
                          return format.format(dt);
                        }

                        if (time != null) {
                          callIntakeController.partnerBirthController.text =
                              formatTimeOfDay(time);
                        }
                      },
                      child: IgnorePointer(
                        child: Column(
                          children: [
                            TextFieldWidget(
                              controller:
                                  callIntakeController.partnerBirthController,
                              labelText: "Partner's Time of Birth",
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  checkColor: Colors.white,
                                  // fillColor: MaterialStateProperty.resolveWith(getColor),
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = value!;
                                    });
                                  },
                                ),
                                CustomText(text: "Don't know ")
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                if (callIntakeController.isEnterPartnerDetails)
                  if (callIntakeController.isEnterPartnerDetails)
                    InkWell(
                      onTap: () {
                        callIntakeController.occupationfocus.unfocus();
                        callIntakeController.partnerNamefocus.unfocus();
                        Get.to(() => PlaceOfBirthSearchScreen(
                              flagId: 6,
                            ));
                      },
                      child: IgnorePointer(
                        child: TextFieldWidget(
                          controller:
                              callIntakeController.partnerPlaceController,
                          labelText: tr('Place of Birth'),
                        ),
                      ),
                    ),
                const SizedBox(
                  height: 60,
                ),
              ],
            );
          }),
        ),
      ),
      bottomSheet: GetBuilder<IntakeController>(builder: (intakeController) {
        return CustomBottomButton(
          onTap: () async {
            double charge = double.parse(widget.rate.toString());
            //double totalMin=int.parse(global.splashController.currentUser!.walletAmount.toString().split(".").first)/int.parse(charge.toString().split(".").first);
            if (charge * time[selectTime] <=
                    global.splashController.currentUser!.walletAmount! ||
                bottomNavigationController.astrologerbyId[0].isFreeAvailable ==
                    true) {
              bool isvalid = intakeController.isValidData();
              print(isvalid);
              if (!isvalid) {
                global.showToast(
                  message: intakeController.errorText,
                  textColor: global.textColor,
                  bgColor: global.toastBackGoundColor,
                );
              } else {
                // print("lat:- ${callIntakeController.lat}");
                // print("long:- ${callIntakeController.long}");
                // print("timezone:- ${callIntakeController.tzone}");

                if (intakeController.isVarified) {
                  global.showOnlyLoaderDialog(context);
                  await callIntakeController.addCallIntakeFormData();
                  if (widget.isFreeAvailable == true) {
                    await intakeController.checkFreeSessionAvailable();
                    if (intakeController.isAddNewRequestByFreeuser == true) {
                      //! false for testing
                      if (widget.type == "Call" || widget.type == "Videocall") {
                        await callController.sendCallRequest(
                            widget.astrologerId,
                            true,
                            widget.type,
                            callIntakeController.freedefaultTime.toString());
                      } else {
                        ChatController chatController =
                            Get.find<ChatController>();
                        DropDownController dropDownController =
                            Get.find<DropDownController>();
                        await chatController.sendMessage(
                            'hi ${widget.astrologerName}  \n\n Below are my details:\n\n'
                                'Name: ${intakeController.nameController.text},\nGender: ${intakeController.gender},\nDOB: ${intakeController.dobController.text},\nTOB: ${intakeController.birthTimeController.text},\nPOB: ${intakeController.placeController.text},\nMarital status: ${dropDownController.maritalStatus ?? "Single"},\nTOPIC: ${dropDownController.topic ?? 'Study'}'
                                '\n\n This is automated message to confirm that chat has started.',
                            '${widget.astrologerId}_${global.currentUserId}',
                            widget.astrologerId,
                            false);

                        if (callIntakeController.isEnterPartnerDetails) {
                          await chatController.sendMessage(
                              'Below are my partner details: \n\n'
                                  'Name: ${intakeController.partnerNameController.text},\nDOB: ${intakeController.partnerDobController.text},\nTOB: ${intakeController.partnerBirthController.text},\nPOB: ${intakeController.partnerPlaceController.text}'
                                  '\n\n This is automated message to confirm that chat has started.'
                                  '',
                              '${widget.astrologerId}_${global.currentUserId}',
                              widget.astrologerId,
                              false);
                        }
                        await chatController.sendChatRequest(
                            widget.astrologerId,
                            true,
                            callIntakeController.freedefaultTime.toString());
                      }
                    } else {
                      global.showToast(
                          message:
                              'You can not join multiple offers at same time',
                          textColor: global.textColor,
                          bgColor: Colors.white);
                    }
                  } else {
                    if (widget.type == "Call" || widget.type == "Videocall") {
                      await callController.sendCallRequest(
                          widget.astrologerId,
                          false,
                          widget.type,
                          (int.parse(time[selectTime]
                                      .toString()
                                      .split(".")
                                      .first) *
                                  60)
                              .toString());
                    } else {
                      ChatController chatController =
                          Get.find<ChatController>();
                      DropDownController dropDownController =
                          Get.find<DropDownController>();
                      await chatController.sendMessage(
                          'hi ${widget.astrologerName}  \n\n Below are my details:\n\n'
                              'Name: ${intakeController.nameController.text},\nGender: ${intakeController.gender},\nDOB: ${intakeController.dobController.text},\nTOB: ${intakeController.birthTimeController.text},\nPOB: ${intakeController.placeController.text},\nMarital status: ${dropDownController.maritalStatus ?? "Single"},\nTOPIC: ${dropDownController.topic ?? 'Study'}'
                              '\n\n This is automated message to confirm that chat has started.',
                          '${widget.astrologerId}_${global.currentUserId}',
                          widget.astrologerId,
                          false);

                      if (callIntakeController.isEnterPartnerDetails) {
                        await chatController.sendMessage(
                            'Below are my partner details: \n\n'
                                'Name: ${intakeController.partnerNameController.text},\nDOB: ${intakeController.partnerDobController.text},\nTOB: ${intakeController.partnerBirthController.text},\nPOB: ${intakeController.partnerPlaceController.text}'
                                '\n\n This is automated message to confirm that chat has started.'
                                '',
                            '${widget.astrologerId}_${global.currentUserId}',
                            widget.astrologerId,
                            false);
                      }
                      await chatController.sendChatRequest(
                          widget.astrologerId,
                          false,
                          (int.parse(time[selectTime]
                                      .toString()
                                      .split(".")
                                      .first) *
                                  60)
                              .toString());
                    }
                  }
                  global.hideLoader();
                  dialogForchat(context);
                } else {
                  global.showToast(
                    message: tr('Please verify your phone number'),
                    textColor: global.textColor,
                    bgColor: global.toastBackGoundColor,
                  );
                }
              }
            } else {
              log("ajksndkjnaskjndk");
              global.showOnlyLoaderDialog(context);
              await walletController.getAmount();
              global.hideLoader();
              openBottomSheetRechrage(
                  context,
                  (charge * time[selectTime]).toString(),
                  '${widget.type}',
                  '${bottomNavigationController.astrologerbyId[0].name}',
                  time[selectTime].toString());
            }
          },
          title:
              '${tr("Start")} ${widget.type} ${tr("with")} ${widget.astrologerName}',
        );
      }),
    );
  }

  void openBottomSheetRechrage(BuildContext context, String minBalance,
      String type, String astrologer, String min) {
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
                                        ? Text('Minimum balance of $min minutes(${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance) is required to start $type with $astrologer ',
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
                                              'Tip:90% users rechage for 10 mins or more.',
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
                          Get.to(() => PaymentInformationScreen(
                              flag: 0,
                              amount: double.parse(
                                  walletController.payment[index])));
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

  dialogForchat(BuildContext context) {
    // BuildContext context = Get.context!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          child: AlertDialog(
            surfaceTintColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 1.w),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            title: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(1.w),
                  child: Center(
                    child: Text(
                      "You're all set!",
                      style: Get.theme.textTheme.displayLarge!.copyWith(
                        color: Colors.black,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                      ),
                    ).tr(),
                  ),
                ),
                SizedBox(height: 4),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              maxRadius: 30,
                              backgroundColor: Get.theme.primaryColor,
                              child: CachedNetworkImage(
                                  imageUrl:
                                      '${global.imgBaseurl}${splashController.currentUser!.profile}',
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage: imageProvider,
                                      ),
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage:
                                            AssetImage(Images.deafultUser),
                                      )),
                            ),
                            SizedBox(height: 2),
                            Text(
                              splashController.currentUser!.name!.isEmpty
                                  ? "User"
                                  : "${splashController.currentUser!.name}",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                        Center(
                          child: Text(
                            "••••",
                            style: TextStyle(
                              color: Colors.pink.shade400,
                              fontSize: 30.sp,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            CircleAvatar(
                              maxRadius: 30,
                              backgroundColor: Get.theme.primaryColor,
                              child: CachedNetworkImage(
                                  imageUrl:
                                      '${global.imgBaseurl}${widget.astrologerProfile}',
                                  imageBuilder: (context, imageProvider) =>
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage: imageProvider,
                                      ),
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage:
                                            AssetImage(Images.deafultUser),
                                      )),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "${widget.astrologerName}",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ).tr(),
                          ],
                        ),
                      ],
                    )),
                // Rest of your content
                SizedBox(height: 4),
                Container(
                  width: MediaQuery.of(context).size.width,
                  // margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.w),
                    border: Border.all(color: Colors.grey, width: 0.3),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        // height: 4.h,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4.w),
                            topRight: Radius.circular(4.w),
                          ),
                          border: Border.all(color: Colors.grey, width: 0.5),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "What's Next! ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 2),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              child: Text(
                                'You will connect with ${widget.astrologerName} after the astrologer accepts your request',
                                style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ).tr(),
                            ),
                            SizedBox(height: 2),
                            // Container(
                            //   padding: EdgeInsets.symmetric(horizontal: 2.w),
                            //   child: Text(
                            //     'AstroPrime will try to answer at least one question in this 5 mins session',
                            //     style: TextStyle(
                            //         fontSize: 15.sp,
                            //         fontWeight: FontWeight.normal,
                            //         color: Colors.black),
                            //   ).tr(),
                            // ),
                          ])
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                          side: BorderSide(color: Colors.pink.shade200),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ).tr(),
                    ),
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding:
                const EdgeInsets.only(bottom: 15, left: 15, right: 15),
          ),
        );
      },
    );
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       surfaceTintColor: Colors.white,
    //       insetPadding: EdgeInsets.symmetric(horizontal: 2.w),
    //       backgroundColor: Colors.white,
    //       contentPadding: EdgeInsets.zero,
    //       shape: const RoundedRectangleBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(10)),
    //       ),
    //       content: SizedBox(
    //         height: 50.h,
    //         width: 90.w,
    //         child: Column(
    //           children: [
    //             Container(
    //               //  height: 5.h,
    //               padding: EdgeInsets.all(2.w),
    //               child: Center(
    //                 child: Text(
    //                   "You're all set!",
    //                   style: Get.theme.textTheme.displayLarge!.copyWith(
    //                     color: Colors.black,
    //                     fontSize: 18.sp,
    //                     fontWeight: FontWeight.w600,
    //                     fontStyle: FontStyle.normal,
    //                   ),
    //                 ).tr(),
    //               ),
    //             ),
    //             SizedBox(height: 1.h),
    //             Container(
    //                 // height: 12.h,
    //                 width: 90.w,
    //                 padding: EdgeInsets.all(2.w),
    //                 decoration: BoxDecoration(
    //                   color: Colors.pink.shade50,
    //                   borderRadius: BorderRadius.circular(10),
    //                 ),
    //                 child: Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   children: [
    //                     Column(
    //                       children: [
    //                         CircleAvatar(
    //                           maxRadius: 30,
    //                           backgroundColor: Get.theme.primaryColor,
    //                           child: CachedNetworkImage(
    //                               imageUrl:
    //                                   '${global.imgBaseurl}${splashController.currentUser!.profile}',
    //                               imageBuilder: (context, imageProvider) =>
    //                                   CircleAvatar(
    //                                     radius: 28,
    //                                     backgroundImage: imageProvider,
    //                                   ),
    //                               placeholder: (context, url) => const Center(
    //                                   child: CircularProgressIndicator()),
    //                               errorWidget: (context, url, error) =>
    //                                   CircleAvatar(
    //                                     radius: 28,
    //                                     backgroundImage:
    //                                         AssetImage(Images.deafultUser),
    //                                   )),
    //                         ),
    //                         SizedBox(height: 1.w),
    //                         Text(
    //                           "${splashController.currentUser!.name}",
    //                           style: TextStyle(
    //                             fontSize: 15.sp,
    //                             fontWeight: FontWeight.normal,
    //                             color: Colors.black,
    //                           ),
    //                         )
    //                       ],
    //                     ),
    //                     Center(
    //                       child: Text(
    //                         "••••",
    //                         style: TextStyle(
    //                           color: Colors.pink.shade400,
    //                           fontSize: 30.sp,
    //                         ),
    //                       ),
    //                     ),
    //                     Column(
    //                       children: [
    //                         CircleAvatar(
    //                           maxRadius: 30,
    //                           backgroundColor: Get.theme.primaryColor,
    //                           child: CachedNetworkImage(
    //                               imageUrl:
    //                                   '${global.imgBaseurl}${widget.astrologerProfile}',
    //                               imageBuilder: (context, imageProvider) =>
    //                                   CircleAvatar(
    //                                     radius: 28,
    //                                     backgroundImage: imageProvider,
    //                                   ),
    //                               placeholder: (context, url) => const Center(
    //                                   child: CircularProgressIndicator()),
    //                               errorWidget: (context, url, error) =>
    //                                   CircleAvatar(
    //                                     radius: 28,
    //                                     backgroundImage:
    //                                         AssetImage(Images.deafultUser),
    //                                   )),
    //                         ),
    //                         SizedBox(height: 1.w),
    //                         Text(
    //                           "${widget.astrologerName}",
    //                           textAlign: TextAlign.right,
    //                           style: TextStyle(
    //                             fontSize: 15.sp,
    //                             fontWeight: FontWeight.normal,
    //                             color: Colors.black,
    //                           ),
    //                         ).tr(),
    //                       ],
    //                     ),
    //                   ],
    //                 )),

    //             // Rest of your content
    //             SizedBox(height: 2.h),
    //             Container(
    //               // height: 22.h,
    //               width: MediaQuery.of(context).size.width,
    //               margin: EdgeInsets.symmetric(horizontal: 4.w),
    //               decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.circular(4.w),
    //                 border: Border.all(color: Colors.grey, width: 0.3),
    //               ),
    //               child: Column(
    //                 children: [
    //                   Container(
    //                     padding: EdgeInsets.all(2.w),

    //                     // height: 4.h,
    //                     width: MediaQuery.of(context).size.width,
    //                     decoration: BoxDecoration(
    //                       color: Colors.grey.shade400,
    //                       borderRadius: BorderRadius.only(
    //                         topLeft: Radius.circular(4.w),
    //                         topRight: Radius.circular(4.w),
    //                       ),
    //                       border: Border.all(color: Colors.grey, width: 0.5),
    //                     ),
    //                     child: Align(
    //                       alignment: Alignment.centerLeft,
    //                       child: Text(
    //                         "What's Next! ",
    //                         style: TextStyle(
    //                           color: Colors.black,
    //                           fontSize: 16.sp,
    //                           fontWeight: FontWeight.bold,
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     // height: 16.h,
    //                     child: Column(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           SizedBox(height: 0.5.h),
    //                           Container(
    //                             height: 9.h,
    //                             width: MediaQuery.of(context).size.width,
    //                             padding: EdgeInsets.symmetric(horizontal: 2.w),
    //                             child: Flexible(
    //                               child: Text(
    //                                 'You will be connecting with ${widget.astrologerName} after the astrologer accepts your request',
    //                                 style: TextStyle(
    //                                     fontSize: 17.sp,
    //                                     fontWeight: FontWeight.normal,
    //                                     color: Colors.black),
    //                               ).tr(),
    //                             ),
    //                           ),
    //                           SizedBox(height: 2.w),
    //                           Container(
    //                             // height: 4.h,
    //                             padding: EdgeInsets.symmetric(horizontal: 2.w),
    //                             child: Text(
    //                               'Astroway will try to answer at least one question in this 5 mins session',
    //                               style: TextStyle(
    //                                   fontSize: 15.sp,
    //                                   fontWeight: FontWeight.normal,
    //                                   color: Colors.black),
    //                             ).tr(),
    //                           ),
    //                         ]),
    //                   )
    //                 ],
    //               ),
    //             ),
    //             SizedBox(height: 1.h),
    //             Padding(
    //               padding: const EdgeInsets.only(top: 4),
    //               child: Container(
    //                 width: MediaQuery.of(context).size.width * 0.6,
    //                 child: ElevatedButton(
    //                   onPressed: () {
    //                     Get.back();
    //                     Get.back();
    //                   },
    //                   style: ElevatedButton.styleFrom(
    //                     backgroundColor: Colors.white,
    //                     shape: RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(5.w),
    //                       side: BorderSide(color: Colors.pink.shade200),
    //                     ),
    //                     shadowColor: Colors.transparent,
    //                   ),
    //                   child: Text(
    //                     'OK',
    //                     style: TextStyle(
    //                       fontSize: 16.sp,
    //                       fontWeight: FontWeight.normal,
    //                       color: Colors.black,
    //                     ),
    //                   ).tr(),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       actionsAlignment: MainAxisAlignment.spaceBetween,
    //       actionsPadding:
    //           const EdgeInsets.only(bottom: 15, left: 15, right: 15),
    //     );
    //   },
    // );
  }
}
