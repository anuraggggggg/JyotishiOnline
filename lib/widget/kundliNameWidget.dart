import 'package:AstrowayCustomer/controllers/kundliController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class KundliNameWidget extends StatelessWidget {
  final KundliController kundliController;
  final VoidCallback onPressed;
  List<TextInputFormatter>? inputFormatters;
  KundliNameWidget(
      {Key? key,
      required this.kundliController,
      required this.onPressed,
      this.inputFormatters})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            inputFormatters: inputFormatters,
            controller: kundliController.userNameController,
            onChanged: (text) {
              kundliController.updateIsDisable();
              kundliController.getName(text);
            },
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
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
                hintText: 'User Name',
                hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.all(0)),
              backgroundColor: WidgetStateProperty.all(
                  kundliController.isDisable
                      ? Color.fromARGB(255, 209, 204, 204)
                      : Get.theme.primaryColor),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: kundliController.isDisable
                            ? Colors.transparent
                            : Colors.grey)),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              'Next',
              textAlign: TextAlign.center,
              style: Get.theme.primaryTextTheme.titleMedium!.copyWith(
                  color: kundliController.isDisable
                      ? Color.fromARGB(255, 100, 98, 98)
                      : Colors.white),
            ).tr(),
          ),
        ),
      ],
    );
  }
}
