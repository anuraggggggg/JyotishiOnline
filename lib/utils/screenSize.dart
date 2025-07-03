import 'package:flutter/cupertino.dart';

dynamic screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

dynamic screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}
