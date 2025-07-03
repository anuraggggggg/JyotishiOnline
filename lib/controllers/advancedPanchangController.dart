import 'package:AstrowayCustomer/controllers/astromallController.dart';
import 'package:AstrowayCustomer/model/advancedPanchangModel.dart';
import 'package:AstrowayCustomer/model/vedicApis/vedicPanchangModel.dart';
import 'package:AstrowayCustomer/utils/services/api_helper.dart';
import 'package:get/get.dart';
import 'package:AstrowayCustomer/utils/global.dart' as global;
import 'package:intl/intl.dart';

class PanchangController extends GetxController {
  APIHelper apiHelper = APIHelper();
  PanchangModel? panchangList;
  VedicPanchangModel ?vedicPanchangModel;

  @override
  void onInit() {
    _inIt();
    super.onInit();
  }

  DateTime now = DateTime.now();
  late String formattedDate = DateFormat('MMM d, EEEE').format(now);

  final AstromallController astromallController = Get.find<AstromallController>();
  _inIt() async {
    getPanchangVedic(DateTime.now());
    astromallController.getAstromallCategory(false);
    print("nextDay");
    print("${DateTime.now().add(Duration(days: -1))}");
  }

  getPanchangDetail({int? day, int? month, int? year, int? hour, int? min, double? lat, double? lon, double? tzone}) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getAdvancedPanchang(day: day, month: month, year: year, hour: hour, min: min, lat: lat, lon: lon, tzone: tzone).then((result) {
            if (result.status == "200") {
              Map<String, dynamic> map = result;
              panchangList = PanchangModel.fromJson(map);
              update();
            } else {
              global.showToast(
                message: 'Failed to get Panchang',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
            update();
          });
        }
      });
    } catch (e) {
      print('Exception in getPanchangDetail():' + e.toString());
    }
  }

  getPanchangVedic(DateTime date)async
  {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getPanchangVedic(date.toString().split(" ").first).then((result) {
            if (result['status'].toString() == "200") {
              Map<String, dynamic> map = result;
              vedicPanchangModel = VedicPanchangModel.fromJson(map);
              update();
            } else {
              global.showToast(
                message: 'Failed to get Panchang',
                textColor: global.textColor,
                bgColor: global.toastBackGoundColor,
              );
            }
            update();
          });
        }
      });
    } catch (e) {
      print('Exception in getPanchangDetail():' + e.toString());
    }
  }

  int prevdate=0;
  int nextdate=0;
   nextDate(bool nextDay)
  {
    nextDay?nextdate++:prevdate--;
    nextDay?getPanchangVedic(DateTime.now().add(Duration(days:nextdate ))):
    getPanchangVedic(DateTime.now().add(Duration(days:prevdate )));

  }



}
