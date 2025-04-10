import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ebird_service.dart';
import '../models/bird.dart';

final ebirdServiceProvider = Provider((ref) => EBirdService());

final selectedRegionProvider = StateProvider<String?>((ref) => null);

final birdsForRegionProvider = FutureProvider<List<Bird>>((ref) async {
  final region = ref.watch(selectedRegionProvider);
  if (region == null) return [];

  final ebirdService = ref.watch(ebirdServiceProvider);
  try {
    return await ebirdService.getBirdsByRegion(region);
  } catch (e) {
    return [];
  }
});

final regionsProvider = FutureProvider<List<String>>((ref) async {
  final ebirdService = ref.watch(ebirdServiceProvider);
  try {
    return await ebirdService.getRegions();
  } catch (e) {
    return [];
  }
});
