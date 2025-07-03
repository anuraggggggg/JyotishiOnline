import 'package:AstrowayCustomer/controllers/astromallController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../widget/commonAppbar.dart';
import '../../widget/customBottomButton.dart';
import '../../widget/textFieldWidget.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

class AddNewAddressScreen extends StatelessWidget {
  final int? id;
  AddNewAddressScreen({Key? key, this.id}) : super(key: key);
  final AstromallController astromallController = AstromallController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CommonAppBar(
            title: id != null ? 'Edit Address' : 'Address',
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 70),
          child:
              GetBuilder<AstromallController>(builder: (astromallController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFieldWidget(
                  controller: astromallController.nameController,
                  labelText: tr('Name'),
                  focusNode: astromallController.namefocus,
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:SizedBox(
                    child: Theme(
                      data: ThemeData(
                        dialogTheme: DialogTheme(
                          contentTextStyle: const TextStyle(color: Colors.white),
                          backgroundColor: Colors.grey[800],
                          surfaceTintColor: Colors.grey[800],
                        ),
                      ),
                      child: InternationalPhoneNumberInput(
                        textFieldController: astromallController.phoneController,
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
                              borderRadius: BorderRadius.all(Radius.circular(2.w)),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            hintText: "Search",
                            hintStyle: const TextStyle(
                              color: Colors.black,
                            )),
                        initialValue:PhoneNumber(isoCode:  'IN') ,
                        formatInput: false,
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: false),
                        inputBorder: InputBorder.none,
                        onSaved: (PhoneNumber number) {
                        },
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        onInputChanged: (PhoneNumber number) {

                        },
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
                  //     astromallController.updateCountryCode(value.code, 1);
                  //   },
                  //   controller: astromallController.phoneController,
                  //   keyboardType: TextInputType.phone,
                  //   cursorColor: global.coursorColor,
                  //   focusNode: astromallController.phone1focus,
                  //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  //   decoration: InputDecoration(
                  //       contentPadding: const EdgeInsets.symmetric(
                  //           vertical: 11, horizontal: 10),
                  //       hintText: tr('Phone Number'),
                  //       errorText: null,
                  //       hintStyle: TextStyle(
                  //         color: Colors.grey,
                  //         fontSize: 16,
                  //         fontFamily: "verdana_regular",
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //       counterText: ''),
                  //   initialCountryCode: astromallController.countryCode ?? 'IN',
                  //   onChanged: (phone) {
                  //     print('length ${phone.number.length}');
                  //   },
                  // )),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:SizedBox(
                    child: InternationalPhoneNumberInput(
                      textFieldController: astromallController.alternatePhoneController,
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
                            borderRadius: BorderRadius.all(Radius.circular(2.w)),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          hintText: "Search",
                          hintStyle: const TextStyle(
                            color: Colors.black,
                          )),
                      initialValue:PhoneNumber(isoCode: astromallController.countryCode2 ?? 'IN') ,
                      formatInput: false,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: false),
                      inputBorder: InputBorder.none,
                      onSaved: (PhoneNumber number) {
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).unfocus();
                      },
                      onInputChanged: (PhoneNumber number) {

                      },
                      onSubmit: () {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  // SizedBox(
                  //     child: IntlPhoneField(
                  //   autovalidateMode: null,
                  //   showDropdownIcon: false,
                  //   onCountryChanged: (value) {
                  //     astromallController.updateCountryCode(value.code, 2);
                  //   },
                  //   controller: astromallController.alternatePhoneController,
                  //   keyboardType: TextInputType.phone,
                  //   cursorColor: global.coursorColor,
                  //   focusNode: astromallController.phone2focus,
                  //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  //   decoration: InputDecoration(
                  //       contentPadding: const EdgeInsets.symmetric(
                  //           vertical: 11, horizontal: 10),
                  //       hintText: 'Alternate phone number',
                  //       errorText: null,
                  //       hintStyle: TextStyle(
                  //         color: Colors.grey,
                  //         fontSize: 16,
                  //         fontFamily: "verdana_regular",
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //       counterText: ''),
                  //   initialCountryCode:
                  //       astromallController.countryCode2 ?? 'IN',
                  //   onChanged: (phone) {
                  //     print('length ${phone.number.length}');
                  //   },
                  // )),
                ),
                TextFieldWidget(
                  controller: astromallController.flatNoController,
                  labelText: 'Flat number',
                  keyboardType: TextInputType.number,
                ),
                TextFieldWidget(
                  controller: astromallController.localityController,
                  labelText: 'Locality',
                ),
                TextFieldWidget(
                  controller: astromallController.landmarkController,
                  labelText: 'Landmark',
                ),
                TextFieldWidget(
                  controller: astromallController.cityController,
                  labelText: 'City',
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ],
                ),
                TextFieldWidget(
                  controller: astromallController.stateController,
                  labelText: 'State/Province',
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ],
                ),
                TextFieldWidget(
                  controller: astromallController.countryController,
                  labelText: 'Country',
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))
                  ],
                ),
                TextFieldWidget(
                  controller: astromallController.pinCodeController,
                  labelText: 'Pincode',
                  keyboardType: TextInputType.number,
                  maxlen: 6,
                ),
              ],
            );
          }),
        ),
      ),
      bottomSheet:
          GetBuilder<AstromallController>(builder: (astromallController) {
        return CustomBottomButton(
          title: 'Continue',
          onTap: () async {
            bool isvalid = astromallController.isValidData();
            if (!isvalid) {
              global.showToast(
                message: astromallController.errorText,
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            } else {
              global.showOnlyLoaderDialog(context);
              if (id != null) {
                await astromallController.updateUserAddress(id!);
                await astromallController.getUserAddressData(
                    global.sp!.getInt("currentUserId") ?? 0);
              } else {
                await astromallController
                    .addAddress(global.sp!.getInt("currentUserId") ?? 0);
                await astromallController.getUserAddressData(
                    global.sp!.getInt("currentUserId") ?? 0);
              }
              global.hideLoader();
              Get.back();
            }
          },
        );
      }),
    );
  }
}
