import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird_list.dart';
import '../models/bird.dart';
import '../providers/ebird_provider.dart';
import '../services/ebird_service.dart';

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

final birdListsProvider =
    StateNotifierProvider<BirdListsNotifier, List<BirdList>>((ref) {
  return BirdListsNotifier();
});

final selectedBirdListProvider = StateProvider<BirdList?>((ref) => null);

final birdsInSelectedListProvider = FutureProvider<List<Bird>>((ref) async {
  final selectedList = ref.watch(selectedBirdListProvider);
  final ebirdService = ref.watch(ebirdServiceProvider);

  if (selectedList == null) {
    return [];
  }

  try {
    final birds = <Bird>[];
    for (final speciesCode in selectedList.birdIds) {
      try {
        final birdData = await ebirdService.getBirdData(speciesCode);
        if (birdData != null) {
          birds.add(Bird(
            speciesCode: birdData['speciesCode'] ?? speciesCode,
            commonName: birdData['comName'] ?? 'Unknown',
            scientificName: birdData['sciName'] ?? 'Unknown',
            family: birdData['familyComName'],
            region: selectedList.regions.first,
            difficulty: 1, // Default difficulty
          ));
        }
      } catch (e) {
        print('Error fetching bird data for $speciesCode: $e');
        // Continue with next bird even if one fails
      }
    }
    print('Successfully fetched ${birds.length} birds');
    return birds;
  } catch (e) {
    print('Error in birdsInSelectedListProvider: $e');
    rethrow;
  }
});
