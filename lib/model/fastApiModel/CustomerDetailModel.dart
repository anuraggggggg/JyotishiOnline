// lib/model/fastApiModel/CustomerDetailModel.dart

class CustomerDetail {
  final String? id;
  final String? name;
  final String? contactNo;

  /// Dates/times are strings in your API (e.g., "2001-09-09", "12.00pm").
  final String? birthDate;
  final String? birthTime;

  final String? profile;            // bio/description
  final String? profileImage;       // file name on server
  final String? profileImageUrl;    // absolute URL (if provided)

  final String? birthPlace;
  final String? addressLine1;
  final String? addressLine2;
  final String? location;

  final int? pincode;

  final String? gender;
  final String? fcmToken;
  final String? token;
  final String? expirationDate;     // string per API (e.g., "2001-09-09T00:00:00")
  final String? countryCode;

  final bool? isActive;
  final bool? isDelete;

  final String? createdAt;          // string (e.g., "2025-10-07T07:55:15")
  final String? updatedAt;          // string

  const CustomerDetail({
    this.id,
    this.name,
    this.contactNo,
    this.birthDate,
    this.birthTime,
    this.profile,
    this.profileImage,
    this.profileImageUrl,
    this.birthPlace,
    this.addressLine1,
    this.addressLine2,
    this.location,
    this.pincode,
    this.gender,
    this.fcmToken,
    this.token,
    this.expirationDate,
    this.countryCode,
    this.isActive,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerDetail.fromJson(Map<String, dynamic> json) {
    return CustomerDetail(
      name:             json['name']?.toString(),
      contactNo:        json['contactNo']?.toString(),
      birthDate:        json['birthDate']?.toString(),
      birthTime:        json['birthTime']?.toString(),
      profile:          json['profile']?.toString(),
      profileImage:     json['profileImage']?.toString(),
      birthPlace:       json['birthPlace']?.toString(),
      addressLine1:     json['addressLine1']?.toString(),
      addressLine2:     json['addressLine2']?.toString(),
      location:         json['location']?.toString(),
      pincode:          json['pincode'] is int ? json['pincode'] as int : int.tryParse('${json['pincode']}'),
      gender:           json['gender']?.toString(),
      fcmToken:         json['fcmToken']?.toString(),
      token:            json['token']?.toString(),
      expirationDate:   json['expirationDate']?.toString(),
      countryCode:      json['countryCode']?.toString(),
      id:               json['id']?.toString(),
      isActive:         json['isActive'] is bool ? json['isActive'] as bool : null,
      isDelete:         json['isDelete'] is bool ? json['isDelete'] as bool : null,
      createdAt:        json['createdAt']?.toString(),
      updatedAt:        json['updatedAt']?.toString(),
      profileImageUrl:  json['profileImageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':               id,
      'name':             name,
      'contactNo':        contactNo,
      'birthDate':        birthDate,
      'birthTime':        birthTime,
      'profile':          profile,
      'profileImage':     profileImage,
      'birthPlace':       birthPlace,
      'addressLine1':     addressLine1,
      'addressLine2':     addressLine2,
      'location':         location,
      'pincode':          pincode,
      'gender':           gender,
      'fcmToken':         fcmToken,
      'token':            token,
      'expirationDate':   expirationDate,
      'countryCode':      countryCode,
      'isActive':         isActive,
      'isDelete':         isDelete,
      'createdAt':        createdAt,
      'updatedAt':        updatedAt,
      'profileImageUrl':  profileImageUrl,
    };
  }

  CustomerDetail copyWith({
    String? id,
    String? name,
    String? contactNo,
    String? birthDate,
    String? birthTime,
    String? profile,
    String? profileImage,
    String? profileImageUrl,
    String? birthPlace,
    String? addressLine1,
    String? addressLine2,
    String? location,
    int?    pincode,
    String? gender,
    String? fcmToken,
    String? token,
    String? expirationDate,
    String? countryCode,
    bool?   isActive,
    bool?   isDelete,
    String? createdAt,
    String? updatedAt,
  }) {
    return CustomerDetail(
      id:               id ?? this.id,
      name:             name ?? this.name,
      contactNo:        contactNo ?? this.contactNo,
      birthDate:        birthDate ?? this.birthDate,
      birthTime:        birthTime ?? this.birthTime,
      profile:          profile ?? this.profile,
      profileImage:     profileImage ?? this.profileImage,
      profileImageUrl:  profileImageUrl ?? this.profileImageUrl,
      birthPlace:       birthPlace ?? this.birthPlace,
      addressLine1:     addressLine1 ?? this.addressLine1,
      addressLine2:     addressLine2 ?? this.addressLine2,
      location:         location ?? this.location,
      pincode:          pincode ?? this.pincode,
      gender:           gender ?? this.gender,
      fcmToken:         fcmToken ?? this.fcmToken,
      token:            token ?? this.token,
      expirationDate:   expirationDate ?? this.expirationDate,
      countryCode:      countryCode ?? this.countryCode,
      isActive:         isActive ?? this.isActive,
      isDelete:         isDelete ?? this.isDelete,
      createdAt:        createdAt ?? this.createdAt,
      updatedAt:        updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CustomerDetail('
        'id: $id, name: $name, contactNo: $contactNo, '
        'birthDate: $birthDate, birthTime: $birthTime, '
        'profile: $profile, profileImage: $profileImage, profileImageUrl: $profileImageUrl, '
        'birthPlace: $birthPlace, addressLine1: $addressLine1, addressLine2: $addressLine2, '
        'location: $location, pincode: $pincode, gender: $gender, '
        'fcmToken: $fcmToken, token: $token, expirationDate: $expirationDate, countryCode: $countryCode, '
        'isActive: $isActive, isDelete: $isDelete, createdAt: $createdAt, updatedAt: $updatedAt'
        ')';
  }
}
