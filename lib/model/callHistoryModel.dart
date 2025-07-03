class CallHistoryModel {
  CallHistoryModel({
    this.id,
    this.userId,
    this.astrologerId,
    this.callStatus,
    this.channelName,
    this.token,
    this.totalMin,
    this.deduction,
    this.astrologerName,
    this.contactNo,
    this.callRate,
    this.profileImage,
    this.charge,
    this.createdAt,
    this.sId,
    this.sId1,
    this.isFreeSession,
    this.callType,
    // this.callDuration,
    // this.updatedAt,
    // this.deductionFromAstrologer
    // this.ch
  });

  dynamic id;
  dynamic userId;
  dynamic astrologerId;
  String? callStatus;
  String? channelName;
  String? token;
  String? totalMin;
  String? callRate;
  dynamic deduction;
  String? astrologerName;
  String? contactNo;
  String? profileImage;
  dynamic charge;
  DateTime? createdAt;
  String? sId;
  String? sId1;
  dynamic isFreeSession;
  dynamic callType;

  // String? callDuration;
  // DateTime? updatedAt;
  // double? deductionFromAstrologer;
  // dynamic chatId;
  // int? callType;

  CallHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    userId = json["userId"] ?? 0;
    astrologerId = json["astrologerId"] ?? 0;
    callStatus = json["callStatus"] ?? "";
    channelName = json["channelName"] ?? "";
    token = json["token"] ?? "";
    totalMin = json["totalMin"] ?? "";
    callRate = json["callRate"] ?? "";
    deduction = json["deduction"] != null ? double.parse(json["deduction"].toString()) : 0;
    astrologerName = json["astrologerName"] ?? "";
    contactNo = json["contactNo"] ?? "";
    profileImage = json["profileImage"] ?? "";
    charge = json["charge"] ?? 0;
    createdAt = json['created_at'] != null ? DateTime.parse(json['created_at'].toString()) : null;
    sId = json['sId'] ?? "";
    sId1 = json['sId1'] ?? "";
    isFreeSession = json['isFreeSession'] ?? false;
    callType = json['call_type'] ?? 0;
  }
}
