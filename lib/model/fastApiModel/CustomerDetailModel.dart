class CustomerDetail {
  final String? birthDate;
  final String? birthTime;
  final String? profile;
  final String? birthPlace;
  final String? addressLine1;
  final String? addressLine2;
  final String? location;
  final int? pincode;
  final String? gender;
  final String? countryCode;
  final bool isActive;
  final bool isDelete;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerDetail({
    this.birthDate,
    this.birthTime,
    this.profile,
    this.birthPlace,
    this.addressLine1,
    this.addressLine2,
    this.location,
    this.pincode,
    this.gender,
    this.countryCode,
    required this.isActive,
    required this.isDelete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerDetail.fromJson(Map<String, dynamic> json) {
    return CustomerDetail(
      birthDate: json['birthDate'],
      birthTime: json['birthTime'],
      profile: json['profile'],
      birthPlace: json['birthPlace'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      location: json['location'],
      pincode: json['pincode'],
      gender: json['gender'],
      countryCode: json['countryCode'],
      isActive: json['isActive'] ?? false,
      isDelete: json['isDelete'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
