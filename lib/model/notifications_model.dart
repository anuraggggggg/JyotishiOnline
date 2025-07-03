class NotificationsModel {
  NotificationsModel({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.notificationId,
    this.createdAt,
    this.chatRequestId,
    this.callRequestId,
    this.isActive,
    this.isDelete,
    this.notificationType,
   // this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.astrologerName,
    this.astrologerId,
    this.astroprofileImage,
    this.fcmToken,
    this.chatId,
    this.callId,
    this.firebaseChatId,
    this.channelName,
    this.totalMin,
    this.callType,
    this.token,
    this.callDuration,
    this.chatDuration,
    this.callStatus,
    this.chatStatus,
  });

  int? id;
  int? userId;
  String? title;
  String? description;
  int? notificationId;
  DateTime? createdAt;
  dynamic chatRequestId;
  int? callRequestId;
  int? isActive;
  int? isDelete;
  int? notificationType;
  //DateTime? createdAt;
  DateTime? updatedAt;
  int? createdBy;
  int? modifiedBy;
  String? astrologerName;
  int? astrologerId;
  String? astroprofileImage;
  dynamic fcmToken;
  dynamic chatId;
  int? callId;
  dynamic firebaseChatId;
  String? channelName;
  dynamic totalMin;
  int? callType;
  String? token;
  dynamic callDuration;
  dynamic chatDuration;
  String? callStatus;
  String? chatStatus;

  factory NotificationsModel.fromJson(Map<String, dynamic> json) => NotificationsModel(
        id: json["id"],
        userId: json["userId"],
        title: json["title"],
        description: json["description"],
        notificationId: json["notificationId"],
        createdAt: DateTime.parse(json["created_at"]),
  //  notificationId: json["notificationId"],
    chatRequestId: json["chatRequestId"],
    callRequestId: json["callRequestId"],
    isActive: json["isActive"],
    isDelete: json["isDelete"],
    notificationType: json["notification_type"],
  //  createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    createdBy: json["createdBy"],
    modifiedBy: json["modifiedBy"],
    astrologerName: json["astrologerName"],
    astrologerId: json["astrologerId"],
    astroprofileImage: json["astroprofileImage"],
    fcmToken: json["fcmToken"],
    chatId: json["chatId"],
    callId: json["callId"],
    firebaseChatId: json["firebaseChatId"],
    channelName: json["channelName"],
    totalMin: json["totalMin"],
    callType: json["call_type"],
    token: json["token"],
    callDuration: json["call_duration"],
    chatDuration: json["chat_duration"],
    callStatus: json["callStatus"],
    chatStatus: json["chatStatus"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "title": title,
        "description": description,
        "notificationId": notificationId,
        "created_at": createdAt!.toIso8601String(),
    "chatRequestId": chatRequestId,
    "callRequestId": callRequestId,
    "isActive": isActive,
    "isDelete": isDelete,
    "notification_type": notificationType,
   // "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "createdBy": createdBy,
    "modifiedBy": modifiedBy,
    "astrologerName": astrologerName,
    "astrologerId": astrologerId,
    "astroprofileImage": astroprofileImage,
    "fcmToken": fcmToken,
    "chatId": chatId,
    "callId": callId,
    "firebaseChatId": firebaseChatId,
    "channelName": channelName,
    "totalMin": totalMin,
    "call_type": callType,
    "token": token,
    "call_duration": callDuration,
    "chat_duration": chatDuration,
    "callStatus": callStatus,
    "chatStatus": chatStatus,
  };
}
