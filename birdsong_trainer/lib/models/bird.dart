class Bird {
  final String name;
  final String scientificName;
  final String speciesCode;
  final String family;
  final String order;
  final String region;
  final String audioUrl;
  final int difficulty; // 1-5 scale
  final String imageUrl;

  Bird({
    required this.name,
    required this.scientificName,
    required this.speciesCode,
    required this.family,
    required this.order,
    required this.region,
    required this.audioUrl,
    required this.difficulty,
    required this.imageUrl,
  });

  factory Bird.fromJson(Map<String, dynamic> json) {
    return Bird(
      name: json['comName'] as String,
      scientificName: json['sciName'] as String,
      speciesCode: json['speciesCode'] as String,
      family: json['familyComName'] as String? ?? 'Unknown',
      order: json['order'] as String? ?? 'Unknown',
      region: json['locName'] as String? ?? 'Unknown',
      audioUrl: '', // We'll need to get this from Xeno-canto
      difficulty: 3, // Default difficulty
      imageUrl: '', // We'll need to get this from another source
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comName': name,
      'sciName': scientificName,
      'speciesCode': speciesCode,
      'familyComName': family,
      'order': order,
      'locName': region,
    };
  }

  factory Bird.fromEBirdJson(Map<String, dynamic> json) {
    print('Creating bird from JSON: $json');
    return Bird(
      name: json['comName'] ?? '',
      scientificName: json['sciName'] ?? '',
      speciesCode: json['speciesCode'] ?? '',
      family: '', // We'll need to get this from another source
      order: '', // We'll need to get this from another source
      region: json['locName'] ?? '',
      audioUrl: '', // We'll need to get this from Xeno-canto
      difficulty: 3, // Default difficulty
      imageUrl: '', // We'll need to get this from another source
    );
  }
}
