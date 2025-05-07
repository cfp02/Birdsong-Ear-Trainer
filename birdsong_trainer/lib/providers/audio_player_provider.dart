import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/xeno_canto_service.dart';

final xenoCantoServiceProvider = Provider<XenoCantoService>((ref) {
  final apiKey = dotenv.env['XENO_CANTO_API_KEY'] ?? '';
  return XenoCantoService(apiKey: apiKey);
});

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AsyncValue<AudioPlayer>>((ref) {
  return AudioPlayerNotifier(ref.watch(xenoCantoServiceProvider));
});

class AudioPlayerNotifier extends StateNotifier<AsyncValue<AudioPlayer>> {
  final XenoCantoService _xenoCantoService;
  AudioPlayer? _player;

  AudioPlayerNotifier(this._xenoCantoService)
      : super(const AsyncValue.loading()) {
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _player = AudioPlayer();
      state = AsyncValue.data(_player!);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> playBirdAudio(String speciesCode, {int sampleCount = 1}) async {
    try {
      final player = _player;
      if (player == null) {
        throw Exception('Audio player not initialized');
      }

      // Stop any currently playing audio
      await player.stop();

      // Get recordings for the species
      final recordings = await _xenoCantoService
          .getRecordingsForSpecies(speciesCode, limit: sampleCount);
      if (recordings.isEmpty) {
        throw Exception('No recordings found for species: $speciesCode');
      }

      // Play each recording in sequence
      for (final recording in recordings) {
        await player.setUrl(recording['file'] as String);
        await player.play();
        await player.seek(Duration.zero);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}
