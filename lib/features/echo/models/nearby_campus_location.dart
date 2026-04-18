class NearbyCampusLocation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String type;
  final int priority;
  final double distanceMeters;

  NearbyCampusLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.type,
    required this.priority,
    required this.distanceMeters,
  });

  factory NearbyCampusLocation.fromJson(Map<String, dynamic> json) {
    return NearbyCampusLocation(
      id: json['id'],
      name: json['name'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
      type: json['type'],
      priority: json['priority'],
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
      'type': type,
      'priority': priority,
      'distanceMeters': distanceMeters,
    };
  }
}