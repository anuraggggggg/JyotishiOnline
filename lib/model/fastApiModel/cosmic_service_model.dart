// lib/model/fastApiModel/cosmic_service_model.dart

class CosmicService {
  final int id;
  final String name;
  final num price;      // Use num to accept both int and double
  final String gst;
  final num finalPrice;  // Use num to accept both int and double
  final String icon;

  CosmicService({
    required this.id,
    required this.name,
    required this.price,
    required this.gst,
    required this.finalPrice,
    required this.icon,
  });

  factory CosmicService.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to num
    num parseToNum(dynamic value) {
      if (value is int) return value;
      if (value is double) return value;
      if (value is String) {
        // Try to parse as double first, then int
        try {
          return double.parse(value);
        } catch (_) {
          return int.parse(value);
        }
      }
      return 0;
    }

    return CosmicService(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: parseToNum(json['price']),
      gst: json['gst'] ?? '',
      finalPrice: parseToNum(json['final_price']),
      icon: json['icon'] ?? '',
    );
  }

  // Helper methods to get price as int (rounded) if needed
  int getPriceAsInt() => price.toInt();
  int getFinalPriceAsInt() => finalPrice.toInt();

  // Helper to get price as double
  double getPriceAsDouble() => price.toDouble();
  double getFinalPriceAsDouble() => finalPrice.toDouble();
}