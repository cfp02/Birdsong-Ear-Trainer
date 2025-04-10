import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_service.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final audioService = AudioService();
  ref.onDispose(() {
    audioService.dispose();
  });
  return audioService;
});
