class Bird {
  final String id;
  final String name;
  final String scientificName;
  final String family;
  final String region;
  final String audioUrl;
  final int difficulty; // 1-5 scale
  final String imageUrl;

  Bird({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.family,
    required this.region,
    required this.audioUrl,
    required this.difficulty,
    required this.imageUrl,
  });

  factory Bird.fromJson(Map<String, dynamic> json) {
    return Bird(
      id: json['id'] as String,
      name: json['name'] as String,
      scientificName: json['scientificName'] as String,
      family: json['family'] as String,
      region: json['region'] as String,
      audioUrl: json['audioUrl'] as String,
      difficulty: json['difficulty'] as int,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'family': family,
      'region': region,
      'audioUrl': audioUrl,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
    };
  }

  factory Bird.fromEBirdJson(Map<String, dynamic> json) {
    print('Creating bird from JSON: $json');
    return Bird(
      id: json['speciesCode'] ?? '',
      name: json['comName'] ?? '',
      scientificName: json['sciName'] ?? '',
      family: '', // We'll need to get this from another source
      region: json['locName'] ?? '',
      audioUrl: '', // We'll need to get this from Xeno-canto
      difficulty: 3, // Default difficulty
      imageUrl: '', // We'll need to get this from another source
    );
  }
}
