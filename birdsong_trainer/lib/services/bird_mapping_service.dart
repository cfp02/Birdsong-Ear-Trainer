import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';

final birdMappingServiceProvider = Provider<BirdMappingService>((ref) {
  return BirdMappingService();
});

class BirdMappingService {
  Future<List<Bird>> getBirdsFromSpeciesCodes(List<String> speciesCodes) async {
    final birds = <Bird>[];

    for (final code in speciesCodes) {
      try {
        // For now, we'll create a basic Bird object with the species code
        // In a real implementation, this would fetch data from a database or API
        birds.add(Bird(
          speciesCode: code,
          commonName: 'Unknown Bird', // Placeholder
          scientificName: 'Unknown Species', // Placeholder
          difficulty: 1, // Default difficulty
        ));
      } catch (e) {
        print('Error mapping species code $code: $e');
      }
    }

    return birds;
  }
}
