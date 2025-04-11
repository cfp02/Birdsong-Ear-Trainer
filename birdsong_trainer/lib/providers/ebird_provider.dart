import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/region.dart';
import '../services/ebird_service.dart';
import '../models/bird.dart';

final ebirdServiceProvider = Provider<EBirdService>((ref) {
  final apiKey = dotenv.env['EBIRD_API_KEY'];
  if (apiKey == null) {
    throw Exception('EBIRD_API_KEY not found in .env file');
  }
  return EBirdService(apiKey: apiKey);
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
