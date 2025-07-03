import 'package:AstrowayCustomer/controllers/bottomNavigationController.dart';
import 'package:AstrowayCustomer/controllers/splashController.dart';
import 'package:AstrowayCustomer/model/Allstories.dart';
import 'package:AstrowayCustomer/model/app_review_model.dart';
import 'package:AstrowayCustomer/model/home_Model.dart';
import 'package:AstrowayCustomer/model/viewStories.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart' as material;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../model/language.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;

class HomeController extends GetxController {
  List<Language> lan = [];
  APIHelper apiHelper = APIHelper();
  var bannerList = <Banner>[];
  var blogList = <Blog>[];
  var astroNews = <AstrotalkInNews>[];
  var astrologyVideo = <AstrologyVideo>[];
  var clientReviews = <AppReviewModel>[];
  var viewSingleStory = <ViewStories>[];
  var allStories = <AllStories>[];
  var myOrders = <TopOrder>[];
  final material.TextEditingController feedbackController =
  material.TextEditingController();
  final SplashController splashController = Get.find<SplashController>();
  final BottomNavigationController bottomNavigationController =
  Get.find<BottomNavigationController>();
  material.PageController pageController = material.PageController().obs();
  int reviewChange = 0.obs();
  VideoPlayerController? videoPlayerController;
  VideoPlayerController? homeVideoPlayerController;
  YoutubePlayerController? youtubePlayerController;

  @override
  void onInit() async {
    _init();
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
          '${global.imgBaseurl}${global.getSystemFlagValueForLogin(global.systemFlagNameList.behindScenes)}'),
    )..initialize().then((_) {
      videoPlayerController!.pause();
      videoPlayerController!.setLooping(true);

      update();
    });

    super.onInit();
  }

  _init() async {
    try {
      await Future.wait([
        getAllStories(),
        getBanner(),
        getBlog(),
        getAstroNews(),
        getMyOrder(),
        getAstrologyVideos(),
        getClientsTestimonals(),
      ]);
      // Calling getLanguages here to ensure it's populated for the dialog
      await getLanguages(); // This will now populate with keys
      bottomNavigationController.astrologerList.clear();
      await bottomNavigationController.getAstrologerList(isLazyLoading: false);
    } catch (e) {
      print("Exception -Homecontroller init future.wait: $e");
    }
  }

  DateTime? currentBackPressTime;
  Future<bool> onBackPressed() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;

      global.showToast(
        message: 'Press again to exit',
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  void playPauseVideo() {
    if (videoPlayerController!.value.isPlaying) {
      videoPlayerController!.pause();
      update();
    } else {
      videoPlayerController!.play();
      update();
    }
  }

  void blogplayPauseVideo(VideoPlayerController controller) {
    if (controller.value.isPlaying) {
      controller.pause();
      update();
    } else {
      controller.play();
      update();
    }
  }

  Future youtubPlay(String url) async {
    String? videoId;
    videoId = YoutubePlayer.convertUrlToId(url);
    youtubePlayerController = YoutubePlayerController(
        initialVideoId: '$videoId',
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          showLiveFullscreenButton: true,
        ));
    update();
  }

  homeBlogVideo(String link) {
    homeVideoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse('${global.imgBaseurl}$link'),
    )..initialize().then((_) {
      homeVideoPlayerController!.pause();
      homeVideoPlayerController!.setLooping(true);
      update();
    });
  }

  int selectedIndex = 0;
  updateLan(int index) {
    selectedIndex = index;
    // Set current language as selected and others as unselected
    for (int i = 0; i < lan.length; i++) {
      lan[i].isSelected = (i == index);
    }
    update();
  }

  Future<void> updateLanIndex() async {
    global.sp = await SharedPreferences.getInstance();
    var currentLan = global.sp!.getString('currentLanguage') ?? 'en';
    for (int i = 0; i < lan.length; i++) {
      if (lan[i].lanCode == currentLan) {
        selectedIndex = i;
        lan[i].isSelected = true;
        update();
      } else {
        lan[i].isSelected = false;
        update();
      }
    }
    print(selectedIndex);
  }

  bool checkBannerValid(
      {required DateTime startDate, required DateTime endDate}) {
    DateTime now = DateTime.now();
    // end date is after or today and sart date is before or today show add
    if (startDate.isBefore(now) && endDate.isAfter(now)) {
      return true;
    }
    return false;
  }

  Future<void> getBanner() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getHomeBanner().then((result) {
            if (result.status == "200") {
              bannerList = result.recordList;
              update();
            } else {
              global.showToast(
                message: 'Failed to get banner',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in getBanner:-" + e.toString());
    }
  }

  Future<void> getBlog() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getHomeBlog().then((result) {
            if (result.status == "200") {
              blogList = result.recordList;
              update();
            } else {
              global.showToast(
                message: 'Failed to get Blogs',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in getBlog:-" + e.toString());
    }
  }

  Future<void> getAstroNews() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAstroNews().then((result) {
            if (result.status == "200") {
              astroNews = result.recordList;
              update();
            } else {
              global.showToast(
                message: 'Failed to get astro news',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  getAstroNews:-" + e.toString());
    }
  }

  Future<void> getMyOrder() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getHomeOrder().then((result) {
            if (result.status == "200") {
              myOrders = result.recordList;
              update();
            } else {
              // global.showToast(
              //   message: 'Failed to get my orders',
              //   textColor: global.textColor,
              //   bgColor: global.toastBackGoundColor,
              // );
            }
          });
        }
      });
    } catch (e) {
      myOrders.clear();
      update();
      print("Exception in getMyOrder:-" + e.toString());
    }
  }

  Future<void> getAstrologyVideos() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAstroVideos().then((result) {
            if (result.status == "200") {
              astrologyVideo = result.recordList;
              update();
            } else {
              global.showToast(
                message: 'Failed to get Astrology video',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  getAstrologyVideos:-" + e.toString());
    }
  }

  Future<void> getClientsTestimonals() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAppReview().then((result) {
            if (result.status == "200") {
              clientReviews = result.recordList;
              update();
            } else {
              // global.showToast(
              //   message: 'Failed to get client testimonals',
              //   textColor: global.textColor,
              //   bgColor: global.toastBackGoundColor,
              // );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  getClientsTestimonals:-" + e.toString());
    }
  }

  incrementBlogViewer(int id) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.viewerCount(id).then((result) {
            if (result.status == "200") {
              print('success');
            } else {
              global.showToast(
                message: 'Faild to increment blog viewer',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in incrementBlogViewer:- " + e.toString());
    }
  }

  addFeedback(String review) async {
    var appReviewModel = {
      "appId": global.appId,
      "review": review,
    };
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.addAppFeedback(appReviewModel).then((result) {
            if (result.status == "200") {
              feedbackController.text = '';

              global.showToast(
                message: 'Thank you!',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            } else {
              global.showToast(
                message: 'Failed to add feedback',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in addFeedback():- " + e.toString());
    }
  }

  // MODIFIED: This method now populates `lan` with translation keys
  Future<void> getLanguages() async {
    try {
      lan.clear();

      lan.add(Language(
        title: 'English', // This is the key for English
        subTitle: 'English', // This is the key for English subtitle
        isSelected: false,
        lanCode: 'en',
      ));

      lan.add(Language(
        title: 'Malayalam', // This is the key for Malayalam (which will resolve to മലയാളം)
        subTitle: 'Malayalam', // This is the key for Malayalam subtitle (which will resolve to Malayalam if present)
        isSelected: false,
        lanCode: 'ml',
      ));

      await updateLanIndex();
      update();
    } catch (e) {
      print("Exception in getLanguages():- " + e.toString());
    }
  }

  Future<void> getAllStories() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAllStory().then((result) {
            if (result.status == "200") {
              allStories = result.recordList;
              update();
            } else {
              // global.showToast(
              //   message: 'Failed to get client testimonals',
              //   textColor: global.textColor,
              //   bgColor: global.toastBackGoundColor,
              // );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  getClientsTestimonals:-" + e.toString());
    }
  }

  Future<void> getAstroStory(String astroId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAstroStory(astroId).then((result) {
            if (result.status == "200") {
              viewSingleStory = result.recordList;
              update();
            } else {
              // global.showToast(
              //   message: 'Failed to get client testimonals',
              //   textColor: global.textColor,
              //   bgColor: global.toastBackGoundColor,
              // );
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  getClientsTestimonals:-" + e.toString());
    }
  }

  Future<void> viewStory(String storyId) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.storyViewed(storyId).then((result) {
            if (result.status == "200") {
              update();
            }
          });
        }
      });
    } catch (e) {
      print("Exception in  storyViewed:-" + e.toString());
    }
  }
}
