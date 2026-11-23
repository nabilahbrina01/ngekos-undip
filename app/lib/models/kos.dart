class Kos {
  final String id;
  final String name;
  final String? areaId;
  final String? areaName;
  final String type; // putra | putri | campur
  final int pricePerMonth;
  final String? address;
  final String? description;
  final List<String> facilities;
  final String? imageUrl;
  final String? ownerName;
  final String? ownerPhone;
  final double? distanceKm;
  final int availableRooms;

  Kos({
    required this.id,
    required this.name,
    required this.type,
    required this.pricePerMonth,
    required this.facilities,
    required this.availableRooms,
    this.areaId,
    this.areaName,
    this.address,
    this.description,
    this.imageUrl,
    this.ownerName,
    this.ownerPhone,
    this.distanceKm,
  });

  factory Kos.fromJson(Map<String, dynamic> json) {
    // "area" berasal dari relasi: select("*, area:areas(id, name)")
    final area = json['area'] as Map<String, dynamic>?;

    return Kos(
      id: json['id'] as String,
      name: json['name'] ?? '-',
      areaId: json['area_id'],
      areaName: area?['name'],
      type: json['type'] ?? 'campur',
      pricePerMonth: (json['price_per_month'] as num?)?.toInt() ?? 0,
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
      availableRooms: (json['available_rooms'] as num?)?.toInt() ?? 0,
    );
  }
}