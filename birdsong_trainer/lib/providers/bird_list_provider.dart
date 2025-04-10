import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird_list.dart';
import '../models/bird.dart';
import '../providers/ebird_provider.dart';

final birdListsProvider =
    StateNotifierProvider<BirdListsNotifier, List<BirdList>>((ref) {
  return BirdListsNotifier();
});

final selectedBirdListProvider = StateProvider<BirdList?>((ref) => null);

class BirdListsNotifier extends StateNotifier<List<BirdList>> {
  BirdListsNotifier() : super(BirdList.predefinedLists);

  void addCustomList(BirdList list) {
    state = [...state, list];
  }

  void removeList(String id) {
    state = state.where((list) => list.id != id).toList();
  }

  void updateList(BirdList updatedList) {
    state = state
        .map((list) => list.id == updatedList.id ? updatedList : list)
        .toList();
  }
}

final birdsInSelectedListProvider = FutureProvider<List<Bird>>((ref) async {
  final selectedList = ref.watch(selectedBirdListProvider);
  if (selectedList == null) return [];

  final ebirdService = ref.watch(ebirdServiceProvider);
  final birds = <Bird>[];

  // For each bird in the list, fetch its details
  for (final birdId in selectedList.birdIds) {
    try {
      // Note: This is a simplified approach. In a real app, you might want to
      // cache these results or use a different endpoint to get multiple birds at once
      final response = await ebirdService.getBirdsByRegion(birdId);
      if (response.isNotEmpty) {
        final birdData = response.first;
        birds.add(Bird.fromJson(birdData));
      }
    } catch (e) {
      print('Error fetching bird $birdId: $e');
    }
  }

  return birds;
});
