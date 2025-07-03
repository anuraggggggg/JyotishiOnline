import 'device_info_login_model.dart';

class LoginModel {
  LoginModel({this.contactNo, this.deviceInfo, this.countryCode,this.email});

  String? contactNo;
  String? email;
  String? countryCode;
  DeviceInfoLoginModel? deviceInfo = DeviceInfoLoginModel();

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        contactNo: json["contactNo"],
        countryCode: json["countryCode"],
    email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "contactNo": contactNo,
        "userDeviceDetails": deviceInfo,
        "countryCode": countryCode,
        "email": email,
      };
}
