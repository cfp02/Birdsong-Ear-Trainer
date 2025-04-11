import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/training_session.dart';
import '../models/bird_list.dart';
import '../models/bird.dart';

final currentTrainingSessionProvider =
    StateProvider<TrainingSession?>((ref) => null);

final trainingProgressProvider = Provider<double>((ref) {
  final session = ref.watch(currentTrainingSessionProvider);
  return session?.progress ?? 0;
});

final trainingSessionNotifierProvider =
    StateNotifierProvider<TrainingSessionNotifier, TrainingSession?>((ref) {
  return TrainingSessionNotifier();
});

class TrainingSessionNotifier extends StateNotifier<TrainingSession?> {
  TrainingSessionNotifier() : super(null);

  void startLearningSession({
    required String name,
    required List<Bird> birds,
    required bool isPreviewMode,
  }) {
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
