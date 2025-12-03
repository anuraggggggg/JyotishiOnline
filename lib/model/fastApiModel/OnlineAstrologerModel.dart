class OnlineAstrologerModel {
  final String id;
  final String name;
  final String profileImage;
  final int chatCharge;
  final int audioCallCharge;
  final int videoCallCharge;
  final String waitTime;

  OnlineAstrologerModel({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.chatCharge,
    required this.audioCallCharge,
    required this.videoCallCharge,
    required this.waitTime,
  });

  factory OnlineAstrologerModel.fromJson(Map<String, dynamic> json) {
    return OnlineAstrologerModel(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      profileImage: json["profileImage"] ?? "",
      chatCharge: json["chatCharge"] ?? 0,
      audioCallCharge: json["audioCallCharge"] ?? 0,
      videoCallCharge: json["videoCallCharge"] ?? 0,
      waitTime: json["waitTime"] ?? "",
    );
  }
}
