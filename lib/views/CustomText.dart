// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  String text;
  double? fontsize;
  Color? color;
  FontWeight? fontWeight;
  TextDecoration? decoration;
  TextDecorationStyle? decorationStyle;
  Color? decorationColor;
  TextAlign? textAlign;
  double? letterSpacing;

  dynamic maxLine;
  dynamic fontFamily;
  dynamic overflow;
  double? height;

  CustomText(
      {Key? key,
      required this.text,
      this.fontWeight,
      this.fontsize,
      this.color,
      this.textAlign,
      this.letterSpacing,
      this.maxLine,
      this.fontFamily,
      fontSize,
      this.overflow,
      this.decoration,
      this.decorationColor,
      this.decorationStyle,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      textScaler: TextScaler.linear(0.85),
      maxLines: maxLine,
      overflow: overflow,
      softWrap: true,
      style: TextStyle(
        decoration: decoration,
        decorationStyle: decorationStyle,
        decorationColor: decorationColor,
        fontSize: fontsize,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color,
        height: height,
        letterSpacing: letterSpacing ?? 0.5,
      ),
    );
  }
}
