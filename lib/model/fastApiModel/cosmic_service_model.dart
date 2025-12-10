class CosmicService {
  final int id;
  final String name;
  final int price;
  final String gst;
  final int finalPrice;
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
    return CosmicService(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      gst: json['gst'],
      finalPrice: json['final_price'],
      icon: json['icon'],
    );
  }
}
