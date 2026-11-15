class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.image,
    required this.origin,
    required this.location,
    required this.episodeCount,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String image;
  final String origin;
  final String location;
  final int episodeCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'species': species,
    'type': type,
    'gender': gender,
    'image': image,
    'origin': {'name': origin},
    'location': {'name': location},
    'episode': List<String>.filled(episodeCount, ''),
  };

  factory Character.fromJson(Map<String, dynamic> json) {
    final origin = json['origin'];
    final location = json['location'];
    final episodes = json['episode'];

    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String,
      image: json['image'] as String,
      origin: origin is Map<String, dynamic>
          ? origin['name'] as String? ?? 'Unknown'
          : 'Unknown',
      location: location is Map<String, dynamic>
          ? location['name'] as String? ?? 'Unknown'
          : 'Unknown',
      episodeCount: episodes is List<dynamic> ? episodes.length : 0,
    );
  }
}
