import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/region.dart';
import '../services/ebird_service.dart';
import '../models/bird.dart';

final ebirdServiceProvider = Provider<EBirdService>((ref) {
  return EBirdService();
});

final regionsProvider = FutureProvider<List<Region>>((ref) async {
  final service = ref.watch(ebirdServiceProvider);
  final regions = await service.getRegions();
  return regions.map((region) => Region.fromJson(region)).toList();
});

final selectedRegionProvider = StateProvider<String>((ref) {
  return 'US-MA'; // Default to Massachusetts
});

final birdsProvider =
    FutureProvider.family<List<Bird>, String>((ref, regionCode) async {
  final service = ref.watch(ebirdServiceProvider);
  final birds = await service.getBirdsByRegion(regionCode);
  return birds.map((bird) => Bird.fromJson(bird)).toList();
});
