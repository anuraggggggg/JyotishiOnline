// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:AstrowayCustomer/controllers/dropDownController.dart';
import 'package:AstrowayCustomer/controllers/kundliMatchingController.dart';
import 'package:AstrowayCustomer/model/getPdfKundali_model.dart';
import 'package:AstrowayCustomer/model/getPdfPrice_model.dart';
import 'package:AstrowayCustomer/model/kundli.dart';
import 'package:AstrowayCustomer/model/kundliBasicDetailMode.dart';
import 'package:AstrowayCustomer/model/kundli_model.dart';
import 'package:AstrowayCustomer/utils/images.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:intl/intl.dart';
class KundliController extends GetxController
    with GetSingleTickerProviderStateMixin {
  TextEditingController userNameController = TextEditingController();
  TextEditingController birthKundliPlaceController = TextEditingController();

  TextEditingController editNameController = TextEditingController();
  TextEditingController editGenderController = TextEditingController();
  TextEditingController editBirthDateController = TextEditingController();
  TextEditingController editBirthTimeController = TextEditingController();
  TextEditingController editBirthPlaceController = TextEditingController();

  String? selectedGender;
  DateTime? selectedDate;
  String? selectedTime;
  double? lat;
  double? long;
  double? timeZone;
  GetPdfKundaliModel? pdfKundaliData;
 // Change to nullable type

  String emptyScreenText = "You haven\'t added any kundli yet!";

  bool isDisable = true;
  bool isTimeOfBirthKnow = false;
  int kundliTabInitialIndex = 5;

  var kundliList = <KundliModel>[];
  var searchKundliList = <KundliModel>[];
  KundliBasicPanchangDetail? kundliBasicPanchangDetail;


  DropDownController dropDownController = Get.find<DropDownController>();

  TabController? tabController;


  // GetPdfKundaliModel? pdfKundaliData;
  GetPdfPrice? pdfPriceData;

  List _kundaliData = [];
  List get kundaliData => _kundaliData;
  int startHouse = 0;

  List name = [];

  APIHelper apiHelper = new APIHelper();
  String prefix = '';
  List<KundliGender> gender = [
    KundliGender(title: 'Male', isSelected: false, image: Images.male),
    KundliGender(title: 'Female', isSelected: false, image: Images.female),
    KundliGender(title: 'Other', isSelected: false, image: Images.otherGender),
  ];
  int initialIndex = 0;
  List kundliTitle = [
    'Hey there! \nWhat is Your name ?',
    'What is your gender?',
    'Enter your birth date',
    'Enter your birth time',
    'Where were you born?'
  ];
  List<Kundli> listIcon = [
    Kundli(icon: Icons.person, isSelected: true),
    Kundli(icon: Icons.search, isSelected: false),
    Kundli(icon: Icons.calendar_month, isSelected: false),
    Kundli(icon: Icons.punch_clock_outlined, isSelected: false),
    Kundli(icon: Icons.location_city, isSelected: false),
  ];

  DateTime editDOB = DateTime.now();
  @override
  void onInit() async {
    tabController = TabController(vsync: this, length: 6);
    // birthPlaceController.text = 'New Delhi, Delhi, India';
    _init();
    //getKundliList();
    super.onInit();
  }

  _init() async {

    await getKundliList();
  }

  backStepForCreateKundli(int index) {
    initialIndex = index;
  }

  updateIcon(index) {
    listIcon[index].isSelected = true;
    for (int i = 0; i < listIcon.length; i++) {
      if (i == index) {
        listIcon[index].isSelected = true;
        continue;
      } else {
        listIcon[i].isSelected = false;
        update();
      }
    }
    update();
  }



  shareKundli(String pdfLink) async {
    try {
      await FlutterShare.share(
              title:
                  '${global.getSystemFlagValueForLogin(global.systemFlagNameList.appName)}',
              text:
                  "Hey! I am using ${global.getSystemFlagValue(global.systemFlagNameList.appName)} to get predictions related to marriage/career.Check my Kundali with .You should also try and see your Kundali ! $pdfLink")
          .then((value) {})
          .catchError((e) {
        print("ajsndkjns");
        print(e);
      });
    } catch (e) {
      print('Excpetion in share kundli $e');
    }
  }



  updateBg(int index) {
    selectedGender = gender[index].title;
    for (int i = 0; i < gender.length; i++) {
      if (i == index) {
        continue;
      } else {
        gender[i].isSelected = false;
      }
    }
    gender[index].isSelected = true;
    update();
  }

  updateAllBg() {
    for (int i = 0; i < gender.length; i++) {
      gender[i].isSelected = false;
    }

    update();
  }

  updateIsDisable() {
    // ignore: unrelated_type_equality_checks
    if (userNameController.text != "") {
      isDisable = false;
      update();
    } else {
      isDisable = true;
      update();
    }
  }

  updateCheck(value) {
    isTimeOfBirthKnow = value;
    update();
  }

  updateInitialIndex() {
    if (initialIndex < 5) {
      initialIndex = initialIndex + 1;
    } else {
      initialIndex = 0;
    }
    update();
  }






  String? dropDownGender;
  List item = ['Male', 'Female', 'Other'];
  String innitialValue(int callId, List<String> item) {
    if (callId == 1) {
      return dropDownGender ?? item[0];
    } else {
      return 'no data';
    }
  }

  void genderChoose(String value) {
    dropDownGender = value;
    update();
  }

  getKundliList() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getKundli().then((result) {
            if (result.status == "200") {
              kundliList = result.recordList;
              searchKundliList = kundliList;
              print("getKundaliList");
              print("${searchKundliList[0].latitude}");
              update();
            } else {
              if (global.currentUserId != null) {
                global.showToast(
                  message: 'FAil to get kundli',
                  textColor: global.textColor,
                  bgColor: global.toastBackGoundColor,
                );
              }
            }
          });
        }
      });
    } catch (e) {
      print('Exception in getKundliList():' + e.toString());
    }
  }

  Future<int> pdfPrice() async {
    int value = 0;
    try {
      await apiHelper.getPdfPrice().then((result) {
        print("getKundaliPrice");
        print("${result.recordList}");
        print("${result.status}");
        if (result.status == "200") {
          Map<String, dynamic> data = jsonDecode(result.recordList);
          pdfPriceData = GetPdfPrice.fromJson(data);
          print("getKundaliPrice");
          print("${pdfPriceData!.recordList}");
          value = 1;
          update();
        } else {
          if (global.currentUserId != null) {
            global.showToast(
              message: 'FAil to get kundli',
              textColor: global.textColor,
              bgColor: global.toastBackGoundColor,
            );
          }
          value = 0;
          // pdfKundaliData=null;
        }
      });
    } catch (e) {
      print("getpdfprice():- $e");
      value = 0;
    }
    return value;
  }

  Future pdfKundali(String id) async {
    try {
      await apiHelper.getPdfKundli(id).then((result) {
        if (result.status == "200") {
          Map<String, dynamic> data = jsonDecode(result.recordList);
          pdfKundaliData = GetPdfKundaliModel.fromJson(data);
          update();
        } else {
          if (global.currentUserId != null) {
            global.showToast(
              message: 'FAil to get kundli',
              textColor: global.textColor,
              bgColor: global.toastBackGoundColor,
            );
          }
          pdfKundaliData = null;
        }
      });
    } catch (e) {
      print("getpdfKundali():- $e");
    }
  }

  getKundliListById(int index) async {
    try {
      editNameController.text = searchKundliList[index].name;
      editBirthDateController.text = formatDate(
          searchKundliList[index].birthDate, [dd, '-', mm, '-', yyyy]);
      editBirthTimeController.text =
          searchKundliList[index].birthTime.toString();
      editBirthPlaceController.text =
          searchKundliList[index].birthPlace.toString();
      editDOB = searchKundliList[index].birthDate;
      update();
      genderChoose(searchKundliList[index].gender);
    } catch (e) {
      print('Exception in getKundliList():' + e.toString());
    }
  }

  String? userName;
  getName(String text) {
    userName = text;
    update();
  }

  getselectedDate(DateTime date) {
    selectedDate = date;
    update();
  }

  getSelectedTime(DateTime date) {
    selectedTime = DateFormat.Hm().format(date);
    update();
  }

  addKundliData(String pdfType,int amount) async {
    List<KundliModel> kundliModel = [
      KundliModel(
          name: userName!,
          gender: selectedGender!,
          birthDate: selectedDate ?? DateTime(1996),
          birthTime: selectedTime ?? DateFormat.jm().format(DateTime.now()),
          birthPlace: birthKundliPlaceController.text,
          latitude: lat,
          longitude: long,
          timezone: timeZone,
          pdf_type: pdfType,
        forMatch: 0,
          lang: dropDownController.kundaliLang.toString()=="English"?'en':(
              dropDownController.kundaliLang.toString()=="Tamil"?'ta':(
                  dropDownController.kundaliLang.toString()=="Kannada"?'ka':
                  (
                      dropDownController.kundaliLang.toString()=="Telugu"?'te':
                      (
                          dropDownController.kundaliLang.toString()=="Hindi"?'hi':
                          (
                              dropDownController.kundaliLang.toString()=="Malayalam"?'ml':
                              (
                                  dropDownController.kundaliLang.toString()=="Spanish"?'sp':
                                  (
                                      dropDownController.kundaliLang.toString()=="French"?'fr':'en'
                                  )
                              )
                          )
                      )
                  )
              )
          )

      )
    ];
    print("languageselect");
    print("${dropDownController.kundaliLang.toString()}");
    update();

    await global.checkBody().then((result) async {
      if (result) {
        await apiHelper.addKundli(kundliModel,amount,false).then((result) {
          if (result.status == "200") {
            print('success');
          } else {
            global.showToast(
              message: 'Failed to create kundli please try again later!',
              textColor: global.textColor,
              bgColor: global.toastBackGoundColor,
            );
          }
        });
      }
    });
  }

  getGeoCodingLatLong(
      {double? latitude,
      double? longitude,
      int? flagId,
      KundliMatchingController? kundliMatchingController}) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .geoCoding(lat: latitude, long: longitude)
              .then((result) {
            if (result.status == "true") {
              if (flagId == 1) {
                kundliMatchingController!.boyTimezone =
                    double.parse(result.recordList['timezone'].toString());
                kundliMatchingController.update();
              } else if (flagId == 2) {
                kundliMatchingController!.girlTimezone =
                    double.parse(result.recordList['timezone'].toString());
                kundliMatchingController.update();
              } else {
                timeZone =
                    double.parse(result.recordList['timezone'].toString());
              }

              print("timezone");
              print("$timeZone");
              update();
            } else {
              global.showToast(
                message: 'NOt Avalilable',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
          });
        }
      });
    } catch (e) {
      print('Exception in getGeoCodingLatLong():' + e.toString());
    }
  }

  DateTime? pickedDate;
  updateKundliData(int id) async {
    KundliModel kundliModel = KundliModel(
      name: editNameController.text,
      gender: dropDownGender!,
      birthDate: pickedDate ?? editDOB,
      birthTime: editBirthTimeController.text,
      birthPlace: editBirthPlaceController.text,
      latitude: lat,
      longitude: long,
    );
    update();
    await global.checkBody().then((result) async {
      if (result) {
        await apiHelper.updateKundli(id, kundliModel).then((result) {
          if (result.status == "200") {
            global.showToast(
              message: 'Your kundli has been updated',
              textColor: global.textColor,
              bgColor: global.toastBackGoundColor,
            );
          } else {
            global.showToast(
              message: 'Failed to update kundli please try again later!',
              textColor: global.textColor,
              bgColor: global.toastBackGoundColor,
            );
          }
        });
      }
    });
  }

  deleteKundli(int id) async {
    await global.checkBody().then((result) async {
      if (result) {
        await apiHelper.deleteKundli(id).then((result) {
          if (result.status == "200") {
            global.showToast(
              message: 'Deleted Successfully',
              textColor: global.textColor,
              bgColor: global.toastBackGoundColor,
            );
          } else {
            global.showToast(
              message: 'Deleted Fail',
              textColor: global.textColor,
              bgColor: global.toastBackGoundColor,
            );
          }
        });
      }
    });
  }

  searchKundli(String kundliName) {
    List<KundliModel> result = [];
    if (kundliName.isEmpty) {
      result = kundliList;
    } else {
      result = kundliList
          .where((element) => element.name
              .toString()
              .toLowerCase()
              .contains(kundliName.toLowerCase()))
          .toList();
    }
    searchKundliList = result;
    if (searchKundliList.isEmpty) {
      emptyScreenText = "Search result not found";
    }
    update();
  }


  getBasicPanchangDetail(
      {int? day,
      int? month,
      int? year,
      int? hour,
      int? min,
      double? lat,
      double? lon,
      double? tzone}) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper
              .getKundliBasicPanchangDetails(
                  day: day,
                  month: month,
                  year: year,
                  hour: hour,
                  min: min,
                  lat: lat,
                  lon: lon,
                  tzone: tzone)
              .then((result) {
            if (result != null) {
              Map<String, dynamic> map = result;
              kundliBasicPanchangDetail =
                  KundliBasicPanchangDetail.fromJson(map);
              update();
            } else {
              global.showToast(
                message: 'Fail to getKundliBasicPanchangDetails',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
            update();
          });
        }
      });
    } catch (e) {
      print('Exception in getBasicPanchangDetail():' + e.toString());
    }
  }
}
