class Bird {
  final String speciesCode;
  final String commonName;
  final String scientificName;
  final String? family;
  final String? region;
  final int? difficulty;

  Bird({
    required this.speciesCode,
    required this.commonName,
    required this.scientificName,
    this.family,
    this.region,
    this.difficulty,
  });

  factory Bird.fromJson(Map<String, dynamic> json) {
    return Bird(
      speciesCode: json['speciesCode'] as String,
      commonName: json['comName'] as String,
      scientificName: json['sciName'] as String,
      family: json['familyComName'] as String?,
      region: json['subnational2Code'] as String?,
      difficulty: 1, // Default difficulty level
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speciesCode': speciesCode,
      'comName': commonName,
      'sciName': scientificName,
      'familyComName': family,
      'subnational2Code': region,
      'difficulty': difficulty,
    };
  }

  factory Bird.fromEBirdJson(Map<String, dynamic> json) {
    print('Creating bird from JSON: $json');
    return Bird(
      speciesCode: json['speciesCode'] ?? '',
      commonName: json['comName'] ?? '',
      scientificName: json['sciName'] ?? '',
      family: '', // We'll need to get this from another source
      region: json['locName'] ?? '',
      difficulty: 3, // Default difficulty
    );
  }
}
