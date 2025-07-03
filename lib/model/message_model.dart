// class MessageModel {
//   int? id;
//   String? message;
//   String? userName;
//   String? profile;
//   bool? isMe;
//   String? gift;
//   MessageModel({this.id, this.message, this.userName, this.profile, this.isMe, this.gift = 'null'});
// }
// class MessageModel {
//   int? id;
//   String? message;
//   String? userName;
//   bool? isMe;
//   String? profile;
//   String? gift;
//   MessageModel({
//     this.id,
//     this.message,
//     this.userName,
//     this.isMe,
//     this.profile,
//     this.gift,
//   });
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  int? id;
  String? message;
  String? userName;
  bool? isMe;
  String? profile;
  String? gift;
  DateTime? createdAt;
  bool? isFromWeb = false;

  MessageModel({
    this.id,
    this.message,
    this.userName,
    this.isMe,
    this.profile,
    this.gift,
    this.createdAt,
    this.isFromWeb,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      message: json['message'],
      userName: json['userName'],
      isMe: json['isMe'],
      profile: json['profile'],
      gift: json['gift'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      isFromWeb: json['isFromWeb'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    data['id'] = id;
    data['message'] = message;
    data['userName'] = userName;
    data['isMe'] = isMe;
    data['profile'] = profile;
    data['gift'] = gift;
    data['createdAt'] = createdAt;
    data['isFromWeb'] = isFromWeb;

    return data;
  }
}
