class Kontrakan {
  final String id;
  final String name;
  final String? areaId;
  final String? areaName;
  final int pricePerYear;
  final int bedrooms;
  final int bathrooms;
  final String? address;
  final String? description;
  final List<String> facilities;
  final String? imageUrl;
  final String? ownerName;
  final String? ownerPhone;
  final double? distanceKm;
  final bool isAvailable;

  Kontrakan({
    required this.id,
    required this.name,
    required this.pricePerYear,
    required this.bedrooms,
    required this.bathrooms,
    required this.facilities,
    required this.isAvailable,
    this.areaId,
    this.areaName,
    this.address,
    this.description,
    this.imageUrl,
    this.ownerName,
    this.ownerPhone,
    this.distanceKm,
  });

  factory Kontrakan.fromJson(Map<String, dynamic> json) {
    final area = json['area'] as Map<String, dynamic>?;

    return Kontrakan(
      id: json['id'] as String,
      name: json['name'] ?? '-',
      areaId: json['area_id'],
      areaName: area?['name'],
      pricePerYear: (json['price_per_year'] as num?)?.toInt() ?? 0,
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      address: json['address'],
      description: json['description'],
      facilities:
          (json['facilities'] as List<dynamic>?)
              ?.map((f) => f.toString())
              .toList() ??
          [],
      imageUrl: json['image_url'],
      ownerName: json['owner_name'],
      ownerPhone: json['owner_phone'],
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      isAvailable: json['is_available'] ?? true,
    );
  }
}