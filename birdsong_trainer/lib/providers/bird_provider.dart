import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bird.dart';
import '../data/sample_birds.dart';

class BirdFilter {
  final String? region;
  final String? family;
  final int? maxDifficulty;

  BirdFilter({
    this.region,
    this.family,
    this.maxDifficulty,
  });

  bool matches(Bird bird) {
    if (region != null && bird.region != region) return false;
    if (family != null && bird.family != family) return false;
    if (maxDifficulty != null && (bird.difficulty ?? 0) > maxDifficulty!)
      return false;
    return true;
  }
}

class BirdNotifier extends StateNotifier<List<Bird>> {
  BirdNotifier() : super(sampleBirds);

  void setFilter(BirdFilter filter) {
    state = sampleBirds.where(filter.matches).toList();
  }

  void clearFilter() {
    state = sampleBirds;
  }

  List<String> get regions => [...Set.from(sampleBirds.map((b) => b.region))];
  List<String> get families => [...Set.from(sampleBirds.map((b) => b.family))];
}

final birdProvider = StateNotifierProvider<BirdNotifier, List<Bird>>((ref) {
  return BirdNotifier();
});

final birdFilterProvider = StateProvider<BirdFilter>((ref) => BirdFilter());
