import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../services/xeno_canto_service.dart';

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier();
});

class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final String? currentBirdId;
  final String? error;

  AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentBirdId,
    this.error,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    String? currentBirdId,
    String? error,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentBirdId: currentBirdId ?? this.currentBirdId,
      error: error ?? this.error,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _player = AudioPlayer();
  final XenoCantoService _xenoCantoService = XenoCantoService();

  AudioPlayerNotifier() : super(AudioPlayerState()) {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        this.state = this.state.copyWith(isPlaying: false);
      }
    });
  }

  Future<void> playBirdSong(String birdId) async {
    try {
      state = state.copyWith(isLoading: true, currentBirdId: birdId);

      // Get audio URL from Xeno-Canto API
      final audioUrl = await _xenoCantoService.getBirdAudioUrl(birdId);

      if (audioUrl == null) {
        throw Exception('No audio available for this bird');
      }

      await _player.setUrl(audioUrl);
      await _player.play();

      state = state.copyWith(
        isPlaying: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> pause() async {
    await _player.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> resume() async {
    await _player.play();
    state = state.copyWith(isPlaying: true);
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(isPlaying: false);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
