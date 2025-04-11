import 'bird.dart';

enum TrainingMode {
  learningPreview, // Show name first, then play song
  learningReinforcement, // Play song first, then show name
  quiz, // Play song, then quiz
  speedId, // Play song, user can stop when they know it
  progressive // Adaptive difficulty
}

class TrainingSession {
  final String id;
  final String name;
  final List<Bird> birds;
  final TrainingMode mode;
  final DateTime createdAt;
  int currentBirdIndex;
  bool isComplete;
  Map<String, bool> learnedBirds; // Track which birds user has learned
  final Set<String> learnedBirdIds;

  TrainingSession({
    required this.id,
    required this.name,
    required this.birds,
    required this.mode,
    DateTime? createdAt,
    this.currentBirdIndex = 0,
    this.isComplete = false,
    Map<String, bool>? learnedBirds,
    this.learnedBirdIds = const {},
  })  : createdAt = createdAt ?? DateTime.now(),
        learnedBirds = learnedBirds ?? {};

  // Create a new learning session
  factory TrainingSession.learning({
    required String name,
    required List<Bird> birds,
    required bool isPreviewMode,
  }) {
    return TrainingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      birds: birds,
      mode: isPreviewMode
          ? TrainingMode.learningPreview
          : TrainingMode.learningReinforcement,
    );
  }

  // Get current bird
  Bird get currentBird => birds[currentBirdIndex];

  // Move to next bird
  bool nextBird() {
    if (currentBirdIndex < birds.length - 1) {
      currentBirdIndex++;
      return true;
    }
    isComplete = true;
    return false;
  }

  // Move to previous bird
  bool previousBird() {
    if (currentBirdIndex > 0) {
      currentBirdIndex--;
      return true;
    }
    return false;
  }

  // Mark bird as learned
  void markBirdAsLearned(Bird bird, bool learned) {
    learnedBirds[bird.speciesCode] = learned;
  }

  // Check if bird is learned
  bool isBirdLearned(Bird bird) {
    return learnedBirds[bird.speciesCode] ?? false;
  }

  // Get progress percentage
  double get progress {
    if (birds.isEmpty) return 0;
    return (currentBirdIndex + 1) / birds.length;
  }

  // Get number of learned birds
  int get learnedCount {
    return learnedBirds.values.where((learned) => learned).length;
  }

  bool get canGoPrevious => currentBirdIndex > 0;
  bool get canGoNext => currentBirdIndex < birds.length - 1;

  TrainingSession copyWith({
    String? name,
    List<Bird>? birds,
    TrainingMode? mode,
    Map<String, bool>? learnedBirds,
    Set<String>? learnedBirdIds,
    int? currentBirdIndex,
  }) {
    return TrainingSession(
      id: id,
      name: name ?? this.name,
      birds: birds ?? this.birds,
      mode: mode ?? this.mode,
      createdAt: createdAt,
      currentBirdIndex: currentBirdIndex ?? this.currentBirdIndex,
      isComplete: isComplete,
      learnedBirds: learnedBirds ?? this.learnedBirds,
      learnedBirdIds: learnedBirdIds ?? this.learnedBirdIds,
    );
  }
}
