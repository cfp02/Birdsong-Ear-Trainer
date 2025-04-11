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
    final speciesCode = json['speciesCode'] as String?;
    final commonName = json['comName'] ?? json['commonName'] as String?;
    final scientificName = json['sciName'] ?? json['scientificName'] as String?;

    if (speciesCode == null || commonName == null || scientificName == null) {
      print('Warning: Missing required fields in bird data:');
      print('speciesCode: $speciesCode');
      print('commonName: $commonName');
      print('scientificName: $scientificName');
      print('Raw JSON: $json');
      throw FormatException('Missing required fields in eBird JSON data');
    }

    return Bird(
      speciesCode: speciesCode,
      commonName: commonName,
      scientificName: scientificName,
      family: json['familyComName'] ?? json['familyName'] as String?,
      region: json['locName'] ?? json['region'] as String?,
      difficulty: 1, // Default to easier difficulty
    );
  }
}
