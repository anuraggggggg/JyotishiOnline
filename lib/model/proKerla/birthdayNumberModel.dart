// lib/model/proKerla/BirthdayNumberModel.dart

class BirthdayNumberModel {
  final String? name;
  final int? number;
  final String? description;

  BirthdayNumberModel({
    this.name,
    this.number,
    this.description,
  });

  factory BirthdayNumberModel.fromJson(Map<String, dynamic> json) {
    // Now `json` is already the "data" map, so look directly under 'birthday_number'
    final bn = json['birthday_number'] as Map<String, dynamic>?;

    if (bn == null) {
      return BirthdayNumberModel();
    }

    return BirthdayNumberModel(
      name: bn['name'] as String?,
      number: (bn['number'] is int) ? bn['number'] as int : null,
      description: bn['description'] as String?,
    );
  }
}
