import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import 'ebird_service.dart';

class BirdMappingService {
  final EBirdService _eBirdService;

  BirdMappingService(this._eBirdService);

  Future<Bird?> getBirdFromSpeciesCode(String speciesCode) async {
    try {
      // First try to get the bird from our predefined list
      final predefinedBirds = await _eBirdService.getPredefinedBirds();
      Bird? foundBird;
      try {
        foundBird = predefinedBirds.firstWhere(
          (b) => b.speciesCode == speciesCode,
        );
      } catch (e) {
        // Bird not found in predefined list
      }

      if (foundBird != null) {
        return foundBird;
      }

      // If not found in predefined list, fetch from eBird API
      final eBirdData = await _eBirdService.getBirdsByRegion(
        regionCode: 'US',
        speciesCode: speciesCode,
      );

      if (eBirdData.isNotEmpty) {
        final birdData = eBirdData.first;
        return Bird(
          speciesCode: birdData['speciesCode'] as String,
          commonName: birdData['comName'] as String,
          scientificName: birdData['sciName'] as String,
          family: birdData['familyComName'] as String?,
          region: 'US',
        );
      }

      return null;
    } catch (e) {
      print('Error mapping bird for species code $speciesCode: $e');
      return null;
    }
  }

  Future<List<Bird>> getBirdsFromSpeciesCodes(List<String> speciesCodes) async {
    final birds = <Bird>[];
    for (final code in speciesCodes) {
      final bird = await getBirdFromSpeciesCode(code);
      if (bird != null) {
        birds.add(bird);
      }
    }
    return birds;
  }
}

final birdMappingServiceProvider = Provider<BirdMappingService>((ref) {
  final eBirdService = ref.watch(eBirdServiceProvider);
  return BirdMappingService(eBirdService);
});
