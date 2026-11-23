class Area {
  final String id;
  final String name;
  final String? description;
  final double? distanceKm;

  Area({
    required this.id,
    required this.name,
    this.description,
    this.distanceKm,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] as String,
      name: json['name'] ?? '-',
      description: json['description'],
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }
}