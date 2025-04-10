import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:birdsong_trainer/services/audio_service.dart';

@GenerateMocks([AudioPlayer])
import 'audio_service_test.mocks.dart';

void main() {
  late AudioService audioService;
  late MockAudioPlayer mockAudioPlayer;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();
    audioService = AudioService();
    audioService.audioPlayer = mockAudioPlayer;
  });

  group('AudioService Tests', () {
    test('playAudio calls setUrl and play', () async {
      const testUrl = 'https://example.com/test.mp3';

      when(mockAudioPlayer.setUrl(testUrl)).thenAnswer((_) async => null);
      when(mockAudioPlayer.play()).thenAnswer((_) async => null);

      await audioService.playAudio(testUrl);

      verify(mockAudioPlayer.setUrl(testUrl)).called(1);
      verify(mockAudioPlayer.play()).called(1);
    });

    test('pauseAudio calls pause', () async {
      when(mockAudioPlayer.pause()).thenAnswer((_) async => null);

      await audioService.pauseAudio();

      verify(mockAudioPlayer.pause()).called(1);
    });

    test('stopAudio calls stop', () async {
      when(mockAudioPlayer.stop()).thenAnswer((_) async => null);

      await audioService.stopAudio();

      verify(mockAudioPlayer.stop()).called(1);
    });

    test('dispose calls dispose', () async {
      when(mockAudioPlayer.dispose()).thenAnswer((_) async => null);

      await audioService.dispose();

      verify(mockAudioPlayer.dispose()).called(1);
    });
  });
}
