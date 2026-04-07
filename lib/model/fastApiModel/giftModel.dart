class GiftModel {
  final int id;
  final String name;
  final String icon;
  final int price;
  final bool isActive;

  GiftModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    required this.isActive,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String,
      price: (json['price'] as num).toInt(),   // ← fixes the crash
      isActive: json['is_active'] as bool,
    );
  }
}