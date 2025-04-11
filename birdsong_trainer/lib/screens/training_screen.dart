import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_player_provider.dart';
import '../providers/training_provider.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayer = ref.watch(audioPlayerProvider);
    final trainingSession = ref.watch(currentTrainingSessionProvider);

    if (trainingSession == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Training'),
        ),
        body: const Center(
          child: Text('No active training session'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(trainingSession.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Show training settings
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (audioPlayer.isLoading)
              const CircularProgressIndicator()
            else if (audioPlayer.error != null)
              Text(
                'Error: ${audioPlayer.error}',
                style: const TextStyle(color: Colors.red),
              )
            else
              IconButton(
                icon: Icon(
                  audioPlayer.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 64,
                ),
                onPressed: () {
                  if (audioPlayer.isPlaying) {
                    ref.read(audioPlayerProvider.notifier).pause();
                  } else {
                    ref.read(audioPlayerProvider.notifier).playBirdSong(
                          trainingSession.currentBird.speciesCode,
                        );
                  }
                },
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // TODO: Show answer options
              },
              child: const Text('Show Answer'),
            ),
          ],
        ),
      ),
    );
  }
}
