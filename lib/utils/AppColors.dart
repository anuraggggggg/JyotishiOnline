import 'package:flutter/material.dart';

//const Color primaryColor = Color(0xffef5350); //#982a35 //EDDD34 //b22b39
const Color primaryLight = Color(0xffefd4d7);
const Color whiteColor = Color(0xffffffff);
const Color buttonTextColor = Color(0xffffffff);
const Color buttonIconColor = Color(0xffffffff);
const Color blackColor = Color(0xff000000);
const Color textColor = Color(0xff000000);
const Color lightGrey = Color(0xfff2f2f3);
const Color colorGrey = Color(0xff676A6C);
const Color orangeColor = Color(0xffffd90d); //#ffd90d //ff5722 //fed700
const Color greenColor = Color(0xff43a047);
const Color lightredColor = Color(0xffe57373);

final List<Color> staticColors = [
  Colors.blue,
  Colors.red,
  Colors.deepOrangeAccent,
  Colors.green,
  Colors.orange,
];

Color getRandomColor(int index) {
  return staticColors[index % staticColors.length];
}
