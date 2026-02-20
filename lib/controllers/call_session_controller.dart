class CallSessionController {
  static final CallSessionController instance =
  CallSessionController._internal();

  CallSessionController._internal();

  bool isActive = false;
  String type = ""; // chat / audio / video
  String roomId = "";
}
