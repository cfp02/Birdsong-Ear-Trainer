import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird_list.dart';
import '../models/bird.dart';
import '../providers/ebird_provider.dart';
import '../services/ebird_service.dart';
import '../services/bird_mapping_service.dart';

class BirdListsNotifier extends StateNotifier<List<BirdList>> {
  BirdListsNotifier() : super(BirdList.predefinedLists);

  void addCustomList(BirdList list) {
    state = [...state, list];
  }

  void removeCustomList(BirdList list) {
    state = state.where((l) => l.id != list.id).toList();
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

  // Special handling for Northeast Warblers list
  if (selectedList.name == 'Northeast Warblers') {
    final ebirdService = ref.watch(ebirdServiceProvider);
    try {
      // Fetch all birds from MA region
      final regionBirds =
          await ebirdService.getBirdsByRegion(regionCode: 'US-MA');

      // Filter for warblers
      final warblers = regionBirds
          .where((bird) {
            final commonName = bird['comName'] as String? ?? '';
            final scientificName = bird['sciName'] as String? ?? '';
            final family = bird['familyComName'] as String? ?? '';

            return commonName.toLowerCase().contains('warbler') ||
                scientificName.toLowerCase().contains('setophaga') ||
                scientificName.toLowerCase().contains('geothlypis') ||
                scientificName.toLowerCase().contains('parkesia') ||
                family.toLowerCase().contains('parulidae');
          })
          .map((birdData) => Bird(
                speciesCode: birdData['speciesCode'] as String,
                commonName: birdData['comName'] as String,
                scientificName: birdData['sciName'] as String,
                family: birdData['familyComName'] as String?,
                region: 'US-MA',
              ))
          .toList();

      print('Found ${warblers.length} warblers in MA region');
      return warblers;
    } catch (e) {
      print('Error fetching warblers: $e');
      return [];
    }
  }

  // For other lists, use the existing mapping service
  final mappingService = ref.watch(birdMappingServiceProvider);
  final birds =
      await mappingService.getBirdsFromSpeciesCodes(selectedList.birdIds);
  print('Found ${birds.length} birds in list ${selectedList.name}');
  return birds;
});
