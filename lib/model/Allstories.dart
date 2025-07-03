// To parse this JSON data, do
//
//     final allStories = allStoriesFromJson(jsonString);



class AllStories {
  int? astrologerId;
  String? name;
  String? profileImage;
  int? storyCount;
  DateTime? latestStoryDate;
  int? allStoriesViewed;

  AllStories({
    this.astrologerId,
    this.name,
    this.profileImage,
    this.storyCount,
    this.latestStoryDate,
    this.allStoriesViewed,
  });

  AllStories copyWith({
    int? astrologerId,
    String? name,
    String? profileImage,
    int? storyCount,
    DateTime? latestStoryDate,
    int? allStoriesViewed,
  }) =>
      AllStories(
        astrologerId: astrologerId ?? this.astrologerId,
        name: name ?? this.name,
        profileImage: profileImage ?? this.profileImage,
        storyCount: storyCount ?? this.storyCount,
        latestStoryDate: latestStoryDate ?? this.latestStoryDate,
        allStoriesViewed: allStoriesViewed ?? this.allStoriesViewed,
      );

  factory AllStories.fromJson(Map<String, dynamic> json) => AllStories(
    astrologerId: json["astrologerId"],
    name: json["name"],
    profileImage: json["profileImage"],
    storyCount: json["story_count"],
    latestStoryDate: json["latest_story_date"] == null ? null : DateTime.parse(json["latest_story_date"]),
    allStoriesViewed: json["allStoriesViewed"],
  );

  Map<String, dynamic> toJson() => {
    "astrologerId": astrologerId,
    "name": name,
    "profileImage": profileImage,
    "story_count": storyCount,
    "latest_story_date": latestStoryDate?.toIso8601String(),
    "allStoriesViewed": allStoriesViewed,
  };
}
