import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird_list.dart';
import '../models/bird.dart';
import '../providers/ebird_provider.dart';
import '../services/ebird_service.dart';
import '../services/bird_mapping_service.dart';

class BirdListsNotifier extends StateNotifier<List<BirdList>> {
  BirdListsNotifier() : super([]);

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
  if (selectedList == null) return [];

  final ebirdService = ref.watch(ebirdServiceProvider);
  final birds = <Bird>[];

  print('Fetching birds for list: ${selectedList.name}');
  print('Bird IDs to fetch: ${selectedList.birdIds}');

  for (final birdId in selectedList.birdIds) {
    try {
      final birdData = await ebirdService.getBirdData(birdId);
      if (birdData != null) {
        print('Successfully fetched data for $birdId: ${birdData['comName']}');
        birds.add(Bird(
          speciesCode: birdData['speciesCode'] as String,
          commonName: birdData['comName'] as String,
          scientificName: birdData['sciName'] as String,
          family: birdData['familyComName'] as String?,
          region: selectedList.regions?.first,
          difficulty: 1, // Default difficulty
        ));
      } else {
        print('No data found for bird ID: $birdId');
      }
    } catch (e) {
      print('Error fetching bird data for $birdId: $e');
    }
  }

  print(
      'Loaded ${birds.length} birds from region ${selectedList.regions?.first}');
  print('Selected bird IDs: ${selectedList.birdIds}');
  return birds;
});
