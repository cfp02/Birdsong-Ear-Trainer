import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../services/database_service.dart';
import '../services/species_reference_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final speciesReferenceServiceProvider =
    Provider<SpeciesReferenceService>((ref) {
  return SpeciesReferenceService();
});

final birdListProvider = FutureProvider<List<Bird>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getBirds();
});

final birdsByRegionProvider =
    FutureProvider.family<List<Bird>, String>((ref, regionCode) async {
  final db = ref.watch(databaseServiceProvider);
  final speciesService = ref.watch(speciesReferenceServiceProvider);

  // First try to get birds from the database
  final birds = await db.getBirds(region: regionCode);

  // If no birds found for this region, fetch and store them
  if (birds.isEmpty) {
    await speciesService.storeBirdsByRegion(regionCode);
    return await db.getBirds(region: regionCode);
  }

  return birds;
});

final birdsByFamilyProvider =
    FutureProvider.family<List<Bird>, String>((ref, family) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getBirds(family: family);
});

final birdsByDifficultyProvider =
    FutureProvider.family<List<Bird>, int>((ref, maxDifficulty) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getBirds(maxDifficulty: maxDifficulty);
});

final birdFilterProvider = StateProvider<BirdFilter>((ref) {
  return BirdFilter();
});

class BirdFilter {
  String? region;
  String? family;
  int? maxDifficulty;

  bool matches(Bird bird) {
    if (region != null && bird.region != region) return false;
    if (family != null && bird.family != family) return false;
    if (maxDifficulty != null && (bird.difficulty ?? 1) > maxDifficulty!)
      return false;
    return true;
  }
}
