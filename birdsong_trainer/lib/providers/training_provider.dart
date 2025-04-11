import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../models/bird_list.dart';
import '../models/bird.dart';

final selectedBirdsProvider = StateProvider<List<Bird>>((ref) => []);

final currentTrainingSessionProvider =
    StateProvider<TrainingSession?>((ref) => null);

final trainingProgressProvider = Provider<double>((ref) {
  final session = ref.watch(currentTrainingSessionProvider);
  return session?.progress ?? 0;
});

final trainingSessionNotifierProvider =
    StateNotifierProvider<TrainingSessionNotifier, TrainingSession?>((ref) {
  return TrainingSessionNotifier(ref);
});

class TrainingSessionNotifier extends StateNotifier<TrainingSession?> {
  final Ref ref;

  TrainingSessionNotifier(this.ref) : super(null);

  void startLearningSession({
    required String name,
    required List<Bird> birds,
    required bool isPreviewMode,
  }) {
    // Update the selected birds provider
    ref.read(selectedBirdsProvider.notifier).state = birds;

    state = TrainingSession.learning(
      name: name,
      birds: birds,
      isPreviewMode: isPreviewMode,
    );
  }

  void nextBird() {
    if (state != null) {
      state!.nextBird();
      state = state; // Trigger rebuild
    }
  }

  void previousBird() {
    if (state != null) {
      state!.previousBird();
      state = state; // Trigger rebuild
    }
  }

  void markBirdAsLearned(Bird bird, bool learned) {
    if (state != null) {
      state!.markBirdAsLearned(bird, learned);
      state = state; // Trigger rebuild
    }
  }

  void endSession() {
    state = null;
  }
}
