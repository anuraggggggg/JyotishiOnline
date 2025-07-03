// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:developer';

import 'package:AstrowayCustomer/model/NorthKundaliMatchingModel.dart';
import 'package:AstrowayCustomer/model/kundliMatchingDetailsModel.dart';
import 'package:AstrowayCustomer/model/kundli_model.dart';
import 'package:AstrowayCustomer/model/southkundaliMatchingModel.dart';
import 'package:AstrowayCustomer/utils/global.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:http/http.dart' as http;

class KundliMatchingController extends GetxController with GetTickerProviderStateMixin {
//Tab Manage
  int currentIndex = 0;
  RxInt homeTabIndex = 0.obs;
  TabController? kundliMatchingTabController;
  APIHelper apiHelper = new APIHelper();
  int? boykundliId;
  int? girlKundliId;
  int? minGirls;
  int? minBoy;
  double? lat;
  double? long;
  double? tzone;
  int? hourGirl;
  int? hourBoy;
  var varnaList = <KundliMatchingDetailModel>[];
  var vashyaList = <KundliMatchingDetailModel>[];
  var taraList = <KundliMatchingDetailModel>[];
  var yoniList = <KundliMatchingDetailModel>[];
  var maitriList = <KundliMatchingDetailModel>[];
  var ganList = <KundliMatchingDetailModel>[];
  var bhakutList = <KundliMatchingDetailModel>[];
  var nadiList = <KundliMatchingDetailModel>[];
  var totalList = <TotalMatchModel>[];
  var conclusionList = <ConclusionModel>[];
  KundliMatchingTitleModel? kundliMatchDetailList;
  bool? isFemaleManglik;
  bool? isMaleManglik;

  @override
  onInit() {
    _init();
    super.onInit();
  }


  String? girlapiTime, boyapiTime;
  ongirlApiTIme(String value) {
    girlapiTime = value;
    debugPrint('girlapiTime is $girlapiTime');
    update();
  }
  onboyApiTime(String value) {
    boyapiTime = value;
    debugPrint('boyapiTime is $boyapiTime');
    update();
  }

  _init() {

    // cBoysBirthTime.text = DateFormat.jm().format(DateTime.now());
    // cGirlBirthTime.text = DateFormat.jm().format(DateTime.now());
    // cBoysBirthPlace.text = "New Delhi,Delhi,India";
    // cGirlBirthPlace.text = "New Delhi,Delhi,India";
  }

  onHomeTabBarIndexChanged(value) {
    homeTabIndex.value = value;
    update();
  }

//Boys Name
  final TextEditingController cBoysName = TextEditingController();
  int ?boyforMatch=1;
  int ?girlforMatch=1;
  double ?boyLat;
  double ?boyLong;
  double ?boyTimezone;
  double ?girlLat;
  double ?girlLong;
  double ?girlTimezone;
//Boys Birth Date
  final TextEditingController cBoysBirthDate = TextEditingController();
   DateTime ?boySelectedDate;
  onBoyDateSelected(DateTime picked) {
    if (picked != boySelectedDate) {
      boySelectedDate = picked;
      cBoysBirthDate.text = boySelectedDate.toString();
      cBoysBirthDate.text = formatDate(boySelectedDate!, [dd, '-', mm, '-', yyyy]);
      update();
    }
  }

//Boys Birthdate Time
  final TextEditingController cBoysBirthTime = TextEditingController();
//Boys Birth Place
  final TextEditingController cBoysBirthPlace = TextEditingController();

//Girls Name
  final TextEditingController cGirlName = TextEditingController();
//Girls Birth Date
  final TextEditingController cGirlBirthDate = TextEditingController();
  DateTime? girlSelectedDate;
  onGirlDateSelected(DateTime picked) {
    if (picked != girlSelectedDate) {
      girlSelectedDate = picked;

      cGirlBirthDate.text = girlSelectedDate.toString();
      cGirlBirthDate.text = formatDate(girlSelectedDate!, [dd, '-', mm, '-', yyyy]);
    }
    update();
  }

//Girls Birthdate Time
  final TextEditingController cGirlBirthTime = TextEditingController();
//Girls Birth Place
  final TextEditingController cGirlBirthPlace = TextEditingController();
  String? errorMessage;

  openKundliData(var kundliList, int index) {
    if (kundliList[index].gender == "Male") {
      onBoyDateSelected(kundliList[index].birthDate);
      boykundliId = kundliList[index].id;
      cBoysName.text = kundliList[index].name;
      cBoysBirthDate.text = formatDate(kundliList[index].birthDate, [dd, '-', mm, '-', yyyy]);
      cBoysBirthTime.text = kundliList[index].birthTime.toString();
      cBoysBirthPlace.text = kundliList[index].birthPlace.toString();
      boyLat=kundliList[index].latitude.toDouble();
      boyLong=kundliList[index].longitude.toDouble();
      boyTimezone=kundliList[index].timezone.toDouble();
      boyforMatch=0;

      update();
    } else if (kundliList[index].gender == "Female") {
      onGirlDateSelected(kundliList[index].birthDate);
      girlKundliId = kundliList[index].id;
      cGirlName.text = kundliList[index].name;
      cGirlBirthDate.text = formatDate(kundliList[index].birthDate, [dd, '-', mm, '-', yyyy]);
      cGirlBirthTime.text = kundliList[index].birthTime.toString();
      cGirlBirthPlace.text = kundliList[index].birthPlace.toString();
      girlLat=kundliList[index].latitude.toDouble();
      girlLong=kundliList[index].longitude.toDouble();
      girlTimezone=kundliList[index].timezone.toDouble();
      girlforMatch=0;
      update();
    }
  }

  bool isValidData() {
    if (cBoysName.text == ""|| cBoysBirthDate.text==""||cBoysBirthTime.text==""|| cBoysBirthPlace.text=="") {
      errorMessage = "Please Input boy\'s detail";
      update();
      return false;
    } else if (cGirlName.text == "" || cGirlBirthDate.text==""||cGirlBirthTime.text==""|| cGirlBirthPlace.text=="") {
      errorMessage = "Please Input Girl\'s detail";
      update();
      return false;
    } else {
      return true;
    }
  }

  NorthKundaliMatchingModel ?northKundaliMatchingModel;
  SouthKundaliMatchingModel ?southKundaliMatchingModel;



  addKundliMatchData(String direction) async {
    global.showOnlyLoaderDialog(Get.context);
    KundliModel sendKundli;
    String lanugagecode = Get.locale!.languageCode;
    List<KundliModel> kundliModel = [
      KundliModel(id: boykundliId, name: cBoysName.text, gender: 'Male',lang:lanugagecode, birthDate: boySelectedDate!, birthTime: cBoysBirthTime.text, birthPlace: cBoysBirthPlace.text, latitude: boyLat, longitude: boyLong,direction: direction,pdf_type: "",timezone:boyTimezone,forMatch: boyforMatch),
      KundliModel(id: girlKundliId, name: cGirlName.text, gender: 'Female',lang: lanugagecode, birthDate: girlSelectedDate!, birthTime: cGirlBirthTime.text, birthPlace: cGirlBirthPlace.text, latitude: girlLat, longitude: girlLong,direction: direction,pdf_type: "",timezone:girlTimezone,forMatch: girlforMatch),
    ];
    southKundaliMatchingModel=null;
    northKundaliMatchingModel=null;
    update();
    await global.checkBody().then((result) async {
      if (result) {
        await apiHelper.addKundli(kundliModel,0,true).then((result) async {
          if (result.status == "200") {
            try {
                  final response = await http.post(
                Uri.parse('$baseUrl/KundaliMatching/report'),
                headers: await global.getApiHeaders(true),
                body: json.encode({"male_kundli_id": result.recordList[0]['id'].toInt(),"female_kundli_id":result.recordList[1]['id'].toInt()}),
              );
              dynamic recordList1;
              print("${response.statusCode}");
              if (response.statusCode == 200) {
                log("${response.body}");
               direction=="South"?
                southKundaliMatchingModel=SouthKundaliMatchingModel.fromJson(jsonDecode(response.body)):
                northKundaliMatchingModel=NorthKundaliMatchingModel.fromJson(jsonDecode(response.body));
                global.hideLoader();
                update();
                update();
              } else {
               // recordList = null;
                global.hideLoader();
              }
            } catch (e) {
              print('Exception:- in addKundli:- ' + e.toString());
              global.hideLoader();
            }
          }
        });
      }
    });
    update();
    update();
  }

  getKundlMatchingiList(DateTime kundliBoys, DateTime kundliGirls) async {
    try {
      kundliMatchDetailList = null;
      DateTime datePanchang = kundliBoys;
      int formattedYear = int.parse(DateFormat('yyyy').format(datePanchang));
      int formattedDay = int.parse(DateFormat('dd').format(datePanchang));
      int formattedMonth = int.parse(DateFormat('MM').format(datePanchang));
      DateTime dateForGirl = kundliGirls;
      int yearGirl = int.parse(DateFormat('yyyy').format(dateForGirl));
      int dayGirl = int.parse(DateFormat('dd').format(dateForGirl));
      int monthGirl = int.parse(DateFormat('MM').format(dateForGirl));
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getMatching(formattedDay, formattedMonth, formattedYear, hourBoy, minBoy, dayGirl, monthGirl, yearGirl, hourGirl, minGirls).then((result) {
            if (result != null) {
              Map<String, dynamic> map = result;
              kundliMatchDetailList = KundliMatchingTitleModel.fromJson(map);
              update();
              print(kundliMatchDetailList);
              update();
            } else {}
          });
        }
      });
    } catch (e) {
      print('Exception in getKundliList():' + e.toString());
    }
  }

  getKundlMagllicList(DateTime kundliBoys, DateTime kundliGirls) async {
    try {
      kundliMatchDetailList = null;
      DateTime datePanchang = kundliBoys;
      int formattedYear = int.parse(DateFormat('yyyy').format(datePanchang));
      int formattedDay = int.parse(DateFormat('dd').format(datePanchang));
      int formattedMonth = int.parse(DateFormat('MM').format(datePanchang));
      DateTime dateForGirl = kundliGirls;
      int yearGirl = int.parse(DateFormat('yyyy').format(dateForGirl));
      int dayGirl = int.parse(DateFormat('dd').format(dateForGirl));
      int monthGirl = int.parse(DateFormat('MM').format(dateForGirl));
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getManglic(formattedDay, formattedMonth, formattedYear, hourBoy, minBoy, dayGirl, monthGirl, yearGirl, hourGirl, minGirls).then((result) {
            if (result != null) {
              isFemaleManglik = result['female']['is_present'];
              isMaleManglik = result['male']['is_present'];
              update();
            } else {}
          });
        }
      });
    } catch (e) {
      print('Exception in getKundliList():' + e.toString());
    }
  }
}
