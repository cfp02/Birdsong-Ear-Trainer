import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioPlayer _audioPlayer = AudioPlayer();

  // Getter for testing purposes
  AudioPlayer get audioPlayer => _audioPlayer;

  // Setter for testing purposes
  set audioPlayer(AudioPlayer player) => _audioPlayer = player;

  Future<void> playAudio(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }

  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<Duration?> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
}
