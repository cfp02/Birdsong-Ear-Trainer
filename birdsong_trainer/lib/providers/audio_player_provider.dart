import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../services/xeno_canto_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final AudioPlayer _player = AudioPlayer();

  AudioPlayerNotifier(this._xenoCantoService)
      : super(const AsyncValue.loading()) {
    state = AsyncValue.data(_player);
  }

  Future<void> playBirdAudio(String speciesCode) async {
    try {
      final audioUrl = await _xenoCantoService.getBirdAudioUrl(speciesCode);
      if (audioUrl != null) {
        await _player.setUrl(audioUrl);
        await _player.play();
      } else {
        print('No audio URL found for species code: $speciesCode');
      }
    } catch (e) {
      print('Error playing bird audio: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
