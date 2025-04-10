import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../models/bird_list.dart';
import '../providers/ebird_provider.dart';

final birdListsProvider =
    StateNotifierProvider<BirdListsNotifier, List<BirdList>>((ref) {
  return BirdListsNotifier();
});

final selectedBirdListProvider = StateProvider<BirdList?>((ref) => null);

final birdsInSelectedListProvider = FutureProvider<List<Bird>>((ref) async {
  final selectedList = ref.watch(selectedBirdListProvider);
  if (selectedList == null) return [];

  final ebirdService = ref.watch(ebirdServiceProvider);
  final birds = <Bird>[];

  // Get the first region from the list, or use a default if none specified
  final region = selectedList.regions?.firstOrNull ?? 'US-MA';
  print('Fetching birds for region: $region');

  try {
    // Fetch all birds for the region first
    final regionBirds = await ebirdService.getBirdsByRegion(region);
    print('Found ${regionBirds.length} birds in region');

    // Convert JSON data to Bird objects and create a map
    final birdMap = <String, Bird>{};
    for (var birdData in regionBirds) {
      try {
        final speciesCode = birdData['speciesCode'] as String?;
        if (speciesCode != null) {
          birdMap[speciesCode] = Bird.fromJson(birdData);
        }
      } catch (e) {
        print('Error converting bird data: $e');
      }
    }

    // Now look up each bird in our list
    for (final bird in selectedList.birds) {
      final speciesCode = bird.speciesCode;
      final regionBird = birdMap[speciesCode];
      if (regionBird != null) {
        birds.add(regionBird);
      } else {
        print('Bird not found in region: $speciesCode');
      }
    }

    print('Found ${birds.length} birds from the list in the region');
    return birds;
  } catch (e) {
    print('Error fetching birds: $e');
    rethrow;
  }
});

class BirdListsNotifier extends StateNotifier<List<BirdList>> {
  BirdListsNotifier() : super(BirdList.predefinedLists);

  void addCustomList(BirdList list) {
    state = [...state, list];
  }

  void removeCustomList(String id) {
    state = state.where((list) => list.id != id).toList();
  }

  void updateCustomList(BirdList updatedList) {
    state = state
        .map((list) => list.id == updatedList.id ? updatedList : list)
        .toList();
  }
}
