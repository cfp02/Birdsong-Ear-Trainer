import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlaybackMode {
  single,
  pair,
  triplet,
}

class TrainingPreferences {
  final bool useShortClips;
  final bool randomizeClipStart;
  final PlaybackMode playbackMode;

  TrainingPreferences({
    this.useShortClips = true,
    this.randomizeClipStart = true,
    this.playbackMode = PlaybackMode.single,
  });

  TrainingPreferences copyWith({
    bool? useShortClips,
    bool? randomizeClipStart,
    PlaybackMode? playbackMode,
  }) {
    return TrainingPreferences(
      useShortClips: useShortClips ?? this.useShortClips,
      randomizeClipStart: randomizeClipStart ?? this.randomizeClipStart,
      playbackMode: playbackMode ?? this.playbackMode,
    );
  }
}

final trainingPreferencesProvider =
    StateNotifierProvider<TrainingPreferencesNotifier, TrainingPreferences>(
  (ref) => TrainingPreferencesNotifier(),
);

class TrainingPreferencesNotifier extends StateNotifier<TrainingPreferences> {
  TrainingPreferencesNotifier() : super(TrainingPreferences());

  void setUseShortClips(bool value) {
    state = state.copyWith(useShortClips: value);
  }

  void setRandomizeClipStart(bool value) {
    state = state.copyWith(randomizeClipStart: value);
  }

  void setPlaybackMode(PlaybackMode mode) {
    state = state.copyWith(playbackMode: mode);
  }
}
